// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import RegexBuilder

import AdventCommon

public enum PacketData: Equatable, Hashable {
    case integer(Int)
    indirect case list(List<PacketData>)

    // MARK: - Loading

    init?<S: StringProtocol & BidirectionalCollection>(
        contentsOf string: S
    ) where S.SubSequence == Substring {
        let tokens = Regex {
            ChoiceOf {
                TryCapture(OneOrMore(.digit)) { Int($0) }
                "["; "]"; ","
            }
        }

        var stack: List<PacketData> = .empty
        self = .list(.empty)
        for token in string.matches(of: tokens).reversed().dropFirst(1) {
            switch token.output {
            case ("]", _):
                stack = .cons(self, stack)
                self = .list(.empty)
            case (_, let parsedNum?):
                let parsedNum: PacketData = .integer(parsedNum)
                switch self {
                case .list(.empty):
                    self = .list(.cons(parsedNum, .empty))
                case .list(let cdr):
                    self = .list(.cons(parsedNum, cdr))
                case let num:
                    self = .list(.cons(parsedNum, .cons(num, .empty)))
                }
            case (",", _):
                continue
            case ("[", _):
                if case let .cons(car, cdr) = stack {
                    switch (car, cdr) {
                    case (.list(let lst), _):
                        self = .list(.cons(self, lst))
                    case (.integer(_), _):
                        self = .list(.cons(self, .cons(car, .empty)))
                    }
                    stack = cdr
                }
            default:
                fatalError("Unexpected token found")
            }
        }
    }

    // MARK: - Printing

    var description: String {
        switch self {
        case .integer(let x):
            return String(x)
        case .list(let lst):
            let arr = lst.lazy.map {
                switch $0 {
                case .list(.empty):
                    return "[]"
                case let lst:
                    return lst.description
                }
            }
            return "[\(arr.joined(separator: ","))]"
        }
    }

    // MARK: - Ordering

    func ordering(comparedTo other: PacketData) -> ComparisonResult {
        switch (self, other) {
        case (.integer(let lhs), .integer(let rhs)):
            if lhs > rhs { return .orderedAscending }
            if lhs < rhs { return .orderedDescending }
            return .orderedSame
        case (.list(.empty), .list(.empty)):
            return .orderedSame
        case (.list(.empty), _):
            return .orderedDescending
        case (_, .list(.empty)):
            return .orderedAscending
        case (.integer(let lhs), .list(let rhs)):
            let llist: PacketData = .list(List(ofOne: .integer(lhs)))
            let rlist: PacketData = .list(rhs)
            return llist.ordering(comparedTo: rlist)
        case (.list(let lhs), .integer(let rhs)):
            let llist: PacketData = .list(lhs)
            let rlist: PacketData = .list(List(ofOne: .integer(rhs)))
            return llist.ordering(comparedTo: rlist)
        case (.list(.cons(let lcar, let lcdr)), .list(.cons(let rcar, let rcdr))):
            switch lcar.ordering(comparedTo: rcar) {
            case .orderedSame:
                return PacketData.list(lcdr).ordering(comparedTo: .list(rcdr))
            case let result:
                return result
            }
        }
    }

    func isOrderedCorrectly(comparedTo other: PacketData) -> Bool {
        return self.ordering(comparedTo: other) == .orderedDescending
    }
}
