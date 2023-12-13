// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day12

open Expecto

open Advent2023.Solutions.Day12

[<Tests>]
let tests =
    testList "Day 12" [
        testList "Examples" [
            let records =
                [ { Springs = "???.###"
                    Groups = [ 1; 1; 3 ] }
                  { Springs = ".??..??...?##."
                    Groups = [ 1; 1; 3 ] }
                  { Springs = "?#?#?#?#?#?#?#?"
                    Groups = [ 1; 3; 1; 6 ] }
                  { Springs = "????.#...#..."
                    Groups = [ 4; 1; 1 ] }
                  { Springs = "????.######..#####."
                    Groups = [ 1; 6; 5 ] }
                  { Springs = "?###????????"
                    Groups = [ 3; 2; 1 ] }
                  { Springs = "?.???.?????????"
                    Groups = [ 1; 1; 1; 2; 1 ] }
                  { Springs = "?.????##??.?#???."
                    Groups = [ 2; 3 ] }
                  { Springs = ".##.?#??.#.?#"
                    Groups = [ 2; 1; 1; 1 ] } ]

            test "Part 1" {
                let expectedArrangementCounts = [ 1L; 4L; 1L; 1L; 4L; 10L; 121L; 2L; 1L ]
                let counts = List.map ConditionRecord.possibleArrangementCount records
                Expect.equal counts expectedArrangementCounts "counts match"
            }

            test "Part 2" {
                let expectedArrangementCounts =
                    [ 1L; 16384L; 1L; 16L; 2500L; 506250L; 2066534377424L; 32L; 1L ]

                let unfoldedRecords = List.map (ConditionRecord.unfold 5) records
                let counts = List.map ConditionRecord.possibleArrangementCount unfoldedRecords

                Expect.equal counts expectedArrangementCounts "counts match"
            }
        ]
    ]
