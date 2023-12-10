// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day9

open Expecto

open Advent2023.Solutions.Day9


[<Tests>]
let tests =
    testList "Day 9" [
        testList "Examples" [
            let reports =
                [ [ 0L; 3L; 6L; 9L; 12L; 15L ]
                  [ 1L; 3L; 6L; 10L; 15L; 21L ]
                  [ 10L; 13L; 16L; 21L; 30L; 45L ] ]

            test "Part 1" {
                let expectedValues = [ 18L; 28L; 68L ]
                let values = List.map Report.nextValue reports
                Expect.equal values expectedValues "expected values match"
            }

            test "Part 2" {
                let expectedValues = [ -3L; 0L; 5L ]
                let values = List.map Report.prevValue reports
                Expect.equal values expectedValues "expected values match"
            }
        ]
    ]
