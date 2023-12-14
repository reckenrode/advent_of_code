// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day13

open Expecto

open Advent2023.Solutions.Day13


[<Tests>]
let tests =
    testList "Day 13" [
        testList "Examples" [
            let patterns =
                [ (Pattern.init [
                      "#.##..##."
                      "..#.##.#."
                      "##......#"
                      "##......#"
                      "..#.##.#."
                      "..##..##."
                      "#.#.##.#."
                  ])
                  (Pattern.init [
                      "#...##..#"
                      "#....#..#"
                      "..##..###"
                      "#####.##."
                      "#####.##."
                      "..##..###"
                      "#....#..#"
                  ]) ]

            let reflections = [ Vertical 5L; Horizontal 4L ]

            testList "Part 1" [
                test "Mirror locations" {
                    let expectedReflections = reflections
                    let reflections = List.map Pattern.findReflection patterns
                    Expect.equal reflections expectedReflections "mirrors match"
                }

                test "Reflection interpretations" {
                    let expectedValues = [ 5L; 400L ]
                    let values = List.map Reflection.interpret reflections
                    Expect.equal values expectedValues "values match"
                }
            ]

            test "Part 2" {
                let expectedReflections = [ Horizontal 3L; Horizontal 1L ]
                let reflections = List.map (Pattern.fixSmudge >> Pattern.findReflection) patterns
                Expect.equal reflections expectedReflections "mirrors match"
            }
        ]
    ]
