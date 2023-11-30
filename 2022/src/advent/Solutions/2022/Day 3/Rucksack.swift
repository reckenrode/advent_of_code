// SPDX-License-Identifier: GPL-3.0-only

struct Rucksack {
    let contents: [Item]

    init?(_ text: some StringProtocol) {
        self.contents = text.compactMap(Item.init)
        guard self.contents.count == text.count else { return nil }
    }

    func shared(with others: some Sequence<Rucksack>) -> [Item] {
        return Array(
            others.reduce(Set(self.contents)) { $0.intersection(Set($1.contents)) }
        )
    }

    var priorityItems: [Item] {
        precondition(self.contents.count % 2 == 0, "rucksack string must be even length")
        let pivot = self.contents.index(self.contents.startIndex, offsetBy: self.contents.count / 2)

        let lhs = Set(self.contents[..<pivot])
        let rhs = Set(self.contents[pivot...])

        return Array(lhs.intersection(rhs))
    }
}
