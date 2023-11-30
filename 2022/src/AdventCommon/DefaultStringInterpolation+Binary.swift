// SPDX-License-Identifier: GPL-3.0-only

public extension DefaultStringInterpolation {
    mutating func appendInterpolation(binary int: some BinaryInteger) {
        let result = String(unsafeUninitializedCapacity: int.bitWidth) { buffer in
            var int = int
            for index in stride(from: int.bitWidth - 1, through: 0, by: -1) {
                buffer[index] = (int & 1) == 1 ? 0x31 : 0x30
                int >>= 1
            }
            return int.bitWidth
        }
        self.appendInterpolation(result)
    }
}
