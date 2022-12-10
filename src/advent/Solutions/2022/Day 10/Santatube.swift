// SPDX-License-Identifier: GPL-3.0-only

import Foundation

import Algorithms

private let dot: UInt8 = 0x2e
private let hash: UInt8 = 0x23
private let newline: UInt8 = 0x0a

extension Solutions.Year2022.Day10 {
    struct Santatube {
        static let width = 40
        static let height = 6

        static let sprite = -1...1

        private var framebuffer = Data(repeating: 0, count: width * height)

        var output: String {
            let outputCapacity = (Self.width + 1) * Self.height
            return String(unsafeUninitializedCapacity: outputCapacity) { buffer in
                var (it, index) = buffer.initialize(
                    from: self.framebuffer
                        .chunks(ofCount: Self.width)
                        .joined(by: newline)
                )
                assert(it.next() == nil, "source should be consumed")
                buffer[index] = newline
                return outputCapacity
            }
        }

        mutating func render(host: Santaputer) {
            var host = host

            self.framebuffer = Data(repeating: dot, count: self.framebuffer.count)

            for row in 0..<Self.height {
                for column in 0..<Self.width {
                    if host.runOneCycle() {
                        let spriteLowerBound = (column+Self.sprite.lowerBound)
                        let spriteUpperBound = (column+Self.sprite.upperBound)
                        let sprite = spriteLowerBound...spriteUpperBound
                        if sprite.contains(host.registers.x) {
                            self.framebuffer[row * Self.width + column] = hash
                        }
                    } else {
                        return
                    }
                }
            }
        }
    }
}
