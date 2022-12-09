// SPDX-License-Identifier: GPL-3.0-only

extension Solutions.Year2022.Day9 {
    struct Knot {
        var name: String
        var position = Point.origin

        func distance(to other: Knot) -> Int {
            let xDelta = self.position.x - other.position.x
            let yDelta = self.position.y - other.position.y
            return Int(Float64(xDelta * xDelta + yDelta * yDelta).squareRoot())
        }

        mutating func move(towards other: Knot, by amount: Int) {
            let xDelta = self.position.x - other.position.x
            let yDelta = self.position.y - other.position.y

            let xAmount = min(amount, abs(xDelta))
            let yAmount = min(amount, abs(yDelta))
            let offset = Offset(x: xAmount * -xDelta.signum(), y: yAmount * -yDelta.signum())
            
            self.position += offset
        }
    }
}

extension Solutions.Year2022.Day9.Knot {
    init(_ text: String) {
        self.name = text
    }
}

extension Solutions.Year2022.Day9.Instruction {
    func apply(to actor: inout Solutions.Year2022.Day9.Knot) {
        switch self {
        case .up:
            actor.position += Offset(x: 0, y: 1)
        case .down:
            actor.position += Offset(x: 0, y: -1)
        case .left:
            actor.position += Offset(x: -1, y: 0)
        case .right:
            actor.position += Offset(x: 1, y: 0)
        }
    }
}
