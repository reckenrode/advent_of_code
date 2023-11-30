// SPDX-License-Identifier: GPL-3.0-only

import Collections

import AdventCommon

class Monkey {
    private static var monkeys: [String: WeakRef<Monkey>] = [:]

    private(set) var items: Deque<SantaItem> = []

    private let pickTarget: (SantaItem) -> String
    
    init(name: String, items: [SantaItem], pickTargetProc: @escaping (SantaItem) -> String) {
        self.pickTarget = pickTargetProc
        self.items.append(contentsOf: items)
        Self.monkeys[name] = WeakRef(obj: self)
    }

    private func `throw`(item: SantaItem, to monkey: Monkey) {
        monkey.items.append(item)
    }

    func inspectAndThrowItems() -> Int {
        let numInspected = self.items.count
        while let item = self.items.popFirst() {
            guard let target = Self.monkeys[self.pickTarget(item)]?.obj else {
                fatalError("Tried to throw to a monkey that doesn’t exist")
            }
            self.throw(item: item, to: target)
        }
        return numInspected
    }
}
