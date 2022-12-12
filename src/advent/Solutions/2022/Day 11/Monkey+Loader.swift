// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder
import System

extension Monkey {
    static func load(from file: FilePath, itemsOwnedBy santa: Santa) throws -> [Monkey] {
        let contents = try String(contentsOfFile: file.string)
        return Self.parseMonkeyArray(from: contents, itemsOwnedBy: santa)
    }

    private static func parseMonkeyArray(
        from input: String,
        itemsOwnedBy santa: Santa
    ) -> [Monkey] {
        var result: [Monkey] = []
        var input = input[...]
        while let parseResult = Self.parseMonkey(from: input, itemsOwnedBy: santa) {
            result.append(parseResult.monkey)
            input = parseResult.rest
        }
        return result
    }

    private static func parseMonkey(
        from input: Substring,
        itemsOwnedBy santa: Santa
    ) -> (monkey: Monkey, rest: Substring)? {
        guard let nameParse = parseName(from: input) else {
            return nil
        }
        guard let itemsParse = parseItems(from: nameParse.rest) else {
            fatalError("Error: failed to parse items and their worries")
        }
        guard let opParse = parseOp(from: itemsParse.rest) else {
            fatalError("Error: failed to parse monkey operation")
        }
        guard let testParse = parseTest(from: opParse.rest) else {
            fatalError("Error: failed to parse monkey test")
        }
        let items = itemsParse.items.map(santa.addItem(withWorry:))
        let monkey = Monkey(name: nameParse.name, items: items) { [weak santa] item in
            guard let santa else { fatalError("Santa unexpectedly disappeared!") }
            opParse.op(santa, item)
            let worry = santa.getWorry(about: item)
            return testParse.test(worry)
        }

        let rest: Substring
        if let next = testParse.rest.firstMatch(of: /^\n/)?.range.upperBound {
            rest = input[next...]
        } else {
            rest = ""
        }

        // This is a hack to avoid overflowing `UInt64`
        santa.updateWorryModulus(testParse.divisor)

        return (monkey: monkey, rest: rest)
    }

    private static func parseName(from input: Substring) -> (name: String, rest: Substring)? {
        guard let line = input.firstMatch(of: /^Monkey (\d+):\n/) else { return nil }
        return (name: String(line.output.1), rest: input[line.range.upperBound...])
    }

    private static func parseItems(
        from input: Substring
    ) -> (items: [Santa.Worry], rest: Substring)? {
        guard let lineStart = input.firstMatch(of: /^  Starting items: ((?:\d+, )*\d+)\n/) else {
            return nil
        }
        let items = lineStart.output.1.matches(
            of: Regex { TryCapture(OneOrMore(.digit), transform: { Santa.Worry(String($0)) }); Optionally(", ") }
        )
        return (items: items.map(\.1), rest: input[lineStart.range.upperBound...])
    }

    private static func parseOp(
        from input: Substring
    ) -> (op: (Santa, SantaItem) -> Void, rest: Substring)? {
        let lineRegex = Regex {
            let op = #/([+\-*/])/#
            let literal = /[[:digit:]]+/
            let item = Capture(ChoiceOf { literal; "old" })
            Anchor.startOfSubject; "  Operation: new = "; item; " "; op; " "; item; "\n"
        }
        let opMapping: [Substring: (Santa.Worry, Santa.Worry) -> Santa.Worry] = [
            "+": (+),
            "-": (-),
            "*": (*),
            "/": (/),
        ]
        guard let line = input.firstMatch(of: lineRegex) else { return nil }
        let op: (Santa.Worry) -> Santa.Worry
        switch line.output {
        case (_, "old", let opString, "old"):
            guard let opFn = opMapping[opString] else { return nil }
            op = { opFn($0, $0) }
        case (_, "old", let opString, let rhs):
            guard
                let rhs = Santa.Worry(String(rhs)),
                let opFn = opMapping[opString]
            else { return nil }
            op = { opFn($0, rhs) }
        case (_, let lhs, let opString, "old"):
            guard
                let lhs = Santa.Worry(String(lhs)),
                let opFn = opMapping[opString]
            else { return nil }
            op = { opFn(lhs, $0) }
        case (_, let lhs, let opString, let rhs):
            guard
                let lhs = Santa.Worry(String(lhs)),
                let rhs = Santa.Worry(String(rhs)),
                let opFn = opMapping[opString]
            else { return nil }
            op = { _ in opFn(lhs, rhs) }
        }
        let proc = { (santa: Santa, item: SantaItem) in
            santa.adjustWorry(for: item, by: op)
            santa.relieveWorry(for: item)
        }
        return (op: proc, rest: input[line.range.upperBound...])
    }

    private static func parseTest(
        from input: Substring
    ) -> (divisor: Santa.Worry, test: (Santa.Worry) -> String, rest: Substring)? {
        guard
            let line = input.firstMatch(of: /^  Test: divisible by (\d+)\n/),
            let divisor = Santa.Worry(String(line.output.1)),
            let trueMonkey = parse(true, from: input[line.range.upperBound...]),
            let falseMonkey = parse(false, from: trueMonkey.rest)
        else { return nil }

        let test = {
            if $0 % divisor == 0 {
                return trueMonkey.monkey
            } else {
                return falseMonkey.monkey
            }
        }
        return (divisor: divisor, test: test, rest: falseMonkey.rest)
    }

    private static func parse(
        _ truthValue: Bool,
        from input: Substring
    ) -> (monkey: String, rest: Substring)? {
        let lineRegex = Regex {
            Anchor.startOfSubject
            "    If \(truthValue): throw to monkey "
            Capture(OneOrMore(.digit))
            "\n"
        }
        guard let line = input.firstMatch(of: lineRegex) else {
            return nil
        }
        return (monkey: String(line.output.1), rest: input[line.range.upperBound...])
    }
}
