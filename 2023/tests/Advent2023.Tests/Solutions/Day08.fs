// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day8

open Expecto

open Advent2023.Solutions.Day8


[<Tests>]
let tests =
    testList "Day 8" [
        testList "Examples" [
            test "Part 1" {
                let maps =
                    [ { Traversals = "RL"
                        Network =
                          [ { Source = "AAA"
                              Destinations = ("BBB", "CCC") }
                            { Source = "BBB"
                              Destinations = ("DDD", "EEE") }
                            { Source = "CCC"
                              Destinations = ("ZZZ", "GGG") }
                            { Source = "DDD"
                              Destinations = ("DDD", "DDD") }
                            { Source = "EEE"
                              Destinations = ("EEE", "EEE") }
                            { Source = "GGG"
                              Destinations = ("GGG", "GGG") }
                            { Source = "ZZZ"
                              Destinations = ("ZZZ", "ZZZ") } ] }
                      { Traversals = "LLR"
                        Network =
                          [ { Source = "AAA"
                              Destinations = ("BBB", "BBB") }
                            { Source = "BBB"
                              Destinations = ("AAA", "ZZZ") }
                            { Source = "ZZZ"
                              Destinations = ("ZZZ", "ZZZ") } ] } ]

                let expectedSteps = [ 2L; 6L ]
                let steps = List.map (GhostMap.traverse ["AAA"] ["ZZZ"]) maps
                Expect.equal steps expectedSteps "steps match"
            }

            test "Part 2" {
                let map =
                    { Traversals = "LR"
                      Network =
                        [ { Source = "11A"
                            Destinations = ("11B", "XXX") }
                          { Source = "11B"
                            Destinations = ("XXX", "11Z") }
                          { Source = "11Z"
                            Destinations = ("11B", "XXX") }
                          { Source = "22A"
                            Destinations = ("22B", "XXX") }
                          { Source = "22B"
                            Destinations = ("22C", "22C") }
                          { Source = "22C"
                            Destinations = ("22Z", "22Z") }
                          { Source = "22Z"
                            Destinations = ("22B", "22B") }
                          { Source = "XXX"
                            Destinations = ("XXX", "XXX") } ] }

                let expectedSteps = 6L
                let steps = GhostMap.traverse ["11A"; "22A"] ["11Z"; "22Z"] map
                Expect.equal steps expectedSteps "steps match"
            }
        ]
    ]
