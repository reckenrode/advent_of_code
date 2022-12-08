// SPDX-License-Identifier: GPL-3.0-only

import System

enum DirectoryEntry {
    case file(name: String, size: UInt64)
    case directory(name: String, children: [FilePath])

    var name: String {
        switch self {
        case .file(let name, _), .directory(let name, _):
            return name
        }
    }

    var isDirectory: Bool {
        switch self {
        case .directory(_, _):
            return true
        default:
            return false
        }
    }

    var isFile: Bool { !isDirectory }
}
