// SPDX-License-Identifier: GPL-3.0-only

import Foundation

import AdventCommon

class Santa {
    typealias Worry = UInt64

    private(set) var belongings: [SantaItem: Worry] = [:]

    private let worryReduction: Worry
    private var worryModulus: Worry = 0

    init(worryReduction: Int) {
        self.worryReduction = Worry(worryReduction)
    }

    func adjustWorry(for item: SantaItem, by proc: (Worry) -> Worry) {
        let currentWorry = self.belongings[item] ?? 0
        self.belongings[item] = proc(currentWorry) % self.worryModulus
    }

    func relieveWorry(for item: SantaItem) {
        self.adjustWorry(for: item) { $0 / self.worryReduction }
    }

    func getWorry(about item: SantaItem) -> Worry {
        return self.belongings[item] ?? 0
    }

    func updateWorryModulus(_ amount: Worry) {
        if self.worryModulus == 0 {
            self.worryModulus = amount
        } else {
            self.worryModulus = self.worryModulus.lcm(amount)
        }
    }

    func addItem(withWorry amount: Worry) -> SantaItem {
        let item = UUID().uuidString
        self.belongings[item] = amount
        return item
    }
}

typealias SantaItem = String
