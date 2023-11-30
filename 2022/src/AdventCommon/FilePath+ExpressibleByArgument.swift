// SPDX-License-Identifier: GPL-3.0-only

import Foundation
import System

import ArgumentParser

extension FilePath: ExpressibleByArgument {
    public init?(argument: String) {
        self = FilePath(argument).lexicallyNormalized()
    }
}
