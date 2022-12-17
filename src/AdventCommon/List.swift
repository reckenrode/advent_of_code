// SPDX-License-Identifier: GPL-3.0-only

public enum List<Element> {
    indirect case cons(Element, List)
    case empty

    public init(_ s: some Sequence<Element>) {
        self = .empty
        for element in s {
            self = .cons(element, self)
        }

        // Manually reverse because `reversed` returns an array
        var other: Self = .empty
        while case let .cons(element, rest) = self {
            self = rest
            other = .cons(element, other)
        }
        self = other
    }

    public var isEmpty: Bool {
        if case .empty = self { return true } else { return false }
    }

    public init(ofOne element: Element) {
        self = .cons(element, .empty)
    }

    public func pop() -> (Element, Self)? {
        switch self {
        case .empty:
            return nil
        case .cons(let car, let cdr):
            return (car, cdr)
        }
    }

    public func prepend(_ element: Element) -> List<Element> {
        return .cons(element, self)
    }
}
