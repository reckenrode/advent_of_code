// SPDX-License-Identifier: GPL-3.0-only

struct Crate: Equatable {
    var label: Character

    var description: String { "[\(self.label)]" }
}

extension Crate {
    init?(text: some StringProtocol) {
        guard let ch = text.first else { return nil }
        self.init(label: ch)
    }
}
