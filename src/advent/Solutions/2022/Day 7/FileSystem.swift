// SPDX-License-Identifier: GPL-3.0-only

import RegexBuilder
import System

struct FileSystem {
    private let entries: [FilePath: DirectoryEntry]

    var directories: [FilePath] {
        get throws {
            func dirs(in pwd: FilePath) throws -> [FilePath] {
                switch (try self.stat(pwd)) {
                case .directory(_, let children):
                    let childDirs = try children.compactMap {
                        let dirent = try self.stat($0)
                        if dirent.isDirectory {
                            return pwd.appending(dirent.name)
                        } else {
                            return nil
                        }
                    }
                    return try childDirs + childDirs.flatMap(dirs(in:))
                default:
                    return []
                }
            }
            return try ["/"] + dirs(in: "/")
        }
    }

    func sizeOf(_ dirent: DirectoryEntry) throws -> UInt64 {
        switch dirent {
        case .file(_, let size):
            return size
        case .directory(_, let children):
            return try children
                .map { try sizeOf(self.stat($0)) }
                .reduce(0, +)
        }
    }

    func stat(_ path: FilePath) throws -> DirectoryEntry {
        guard let result = self.entries[path] else {
            throw Errno.noSuchFileOrDirectory
        }
        return result
    }
}

extension FileSystem {
    init?(from commands: String) {
        let linePattern = Regex {
            let cdCmd = #/\$ cd ([[:alpha:]]+|\.\.|/)/#
            let lsCmd = /\$ ls/
            let dirPattern = /dir ([[:alpha:]]+)/
            let filePattern = Regex {
                TryCapture(OneOrMore(.digit), transform: { UInt64($0) }); " "; /([^\0\n]+)/
            }
            ChoiceOf { cdCmd; lsCmd; dirPattern; filePattern }; "\n"
        }

        let lines = commands.matches(of: linePattern)
        guard let first = lines.first, first.output.1 == "/" else { return nil }

        var entries: [FilePath: DirectoryEntry] = [:]

        var pwd = FilePath("/")
        for line in lines[1...] {
            switch line.output {
            case (_, _, _, let size?, let filename?):
                let newDirent = DirectoryEntry.file(name: String(filename), size: size)
                Self.updateEntry(&entries, at: pwd, value: newDirent)
            case (_, _, let dirName?, _, _):
                let newDirent = DirectoryEntry.directory(name: String(dirName), children: [])
                Self.updateEntry(&entries, at: pwd, value: newDirent)
            case (_, let newDir, _, _, _) where newDir == "..":
                if pwd.components.popLast() == nil {
                    fatalError("Attempted to cd up from the root directory")
                }
            case (_, let newDir?, _, _, _):
                pwd.append(String(newDir))
            default:
                continue
            }
        }

        self.entries = entries
    }

    static func updateEntry(
        _ entries: inout [FilePath: DirectoryEntry],
        at pwd: FilePath,
        value: DirectoryEntry
    ) {
        let pwdName = pwd.lastComponent?.string ?? "/"
        let defaultPwdDirent = DirectoryEntry.directory(name: pwdName, children: [])

        // Temporarily remove the entry from the collection to avoid copy-on-write
        // when appending the current path to its children.
        guard
            case .directory(let name, var children) = entries[pwd] ?? defaultPwdDirent
        else {
            fatalError("Attempted to add directory entries to a file")
        }
        entries[pwd] = nil

        let path = pwd.appending(value.name)
        children.append(path)

        entries[path] = value
        entries[pwd] = .directory(name: name, children: children)
    }
}
