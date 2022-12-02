// SPDX-License-Identifier: GPL-3.0-only

enum RPSPlay {
    case Rock, Paper, Scissors

    var value: Int {
        switch self {
        case .Rock:
            return 1
        case .Paper:
            return 2
        case .Scissors:
            return 3
        }
    }

    init?(parsing string: some StringProtocol) {
        switch string {
        case "A", "X":
            self = .Rock
        case "B", "Y":
            self = .Paper
        case "C", "Z":
            self = .Scissors
        default:
            return nil
        }
    }

    func score(against play: RPSPlay) -> Int {
        switch (self, play) {
        case (.Paper, .Rock), (.Rock, .Scissors), (.Scissors, .Paper):
            return 6 + self.value
        case (.Rock, .Rock), (.Paper, .Paper), (.Scissors, .Scissors):
            return 3 + self.value
        default:
            return 0 + self.value
        }
    }
}

enum RPSOutcome {
    case Win, Lose, Draw

    init?(parsing string: some StringProtocol) {
        switch string {
        case "X":
            self = .Lose
        case "Y":
            self = .Draw
        case "Z":
            self = .Win
        default:
            return nil
        }
    }

    func shouldPlay(against play: RPSPlay) -> RPSPlay {
        switch (self, play) {
        case (.Win, .Rock), (.Lose, .Scissors), (.Draw, .Paper):
            return .Paper
        case (.Win, .Paper), (.Lose, .Rock), (.Draw, .Scissors):
            return .Scissors
        case (.Win, .Scissors), (.Lose, .Paper), (.Draw, .Rock):
            return .Rock
        }
    }
}
