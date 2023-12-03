// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Day1

open Expecto

open Advent2023.Solutions.Day1

[<Tests>]
let tests =
    testList "Day 1" [
        testList "Examples" [
            test "Example 1" {
                let expectedValues = [ 12; 38; 15; 77 ]
                let example = [ "1abc2"; "pqr3stu8vwx"; "a1b2c3d4e5f"; "treb7uchet" ]
                let values = calibrate example
                Expect.equal values expectedValues "the lines add up"
            }

            test "Example 2" {
                let expectedValues = [ 29; 83; 13; 24; 42; 14; 76 ]

                let example =
                    [ "two1nine"
                      "eightwothree"
                      "abcone2threexyz"
                      "xtwone3four"
                      "4nineeightseven2"
                      "zoneight234"
                      "7pqrstsixteen" ]

                let values = calibrate example
                Expect.equal values expectedValues "the lines add up"
            }
        ]

        testList "When there are multiple digits" [
            test "It parses only the first and last" {
                let expectedValues = [ 42 ]
                let values = calibrate [ "4294342982" ]
                Expect.equal values expectedValues "just 42"
            }
        ]
    ]
