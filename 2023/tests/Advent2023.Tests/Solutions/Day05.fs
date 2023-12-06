// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day5


open Expecto

open Advent2023.Solutions.Day5


[<Tests>]
let tests =
    testList "Day 5" [
        testList "Examples" [
            let seeds = [ 79L; 14L; 55L; 13L ]

            let mappings =
                Map [
                    "seed-to-soil", [ 50L, 98L, 2L; 52L, 50L, 48L ]
                    "soil-to-fertilizer", [ 0L, 15L, 37L; 37L, 52L, 2L; 39L, 0L, 15L ]
                    "fertilizer-to-water", [ 49L, 53L, 8L; 0L, 11L, 42L; 42L, 0L, 7L; 57L, 7L, 4L ]
                    "water-to-light", [ 88L, 18L, 7L; 18L, 25L, 70L ]
                    "light-to-temperature", [ 45L, 77L, 23L; 81L, 45L, 19L; 68L, 64L, 13L ]
                    "temperature-to-humidity", [ 0L, 69L, 1L; 1L, 0L, 69L ]
                    "humidity-to-location", [ 60L, 56L, 37L; 56L, 93L, 4L ]
                ]

            test "Part 1" {
                let expectedSoilNumbers = [ 82L; 43L; 86L; 35L ]
                let findSoil = solver part1mapper mappings
                let soilNumbers = List.map findSoil seeds
                Expect.equal soilNumbers expectedSoilNumbers "soil numbers match"
            }

            test "Part 2" {
                let expectedSoilRanges =
                    [ { Start = 46L; End = 55L }
                      { Start = 56L; End = 59L }
                      { Start = 60L; End = 60L }
                      { Start = 82L; End = 84L }
                      { Start = 86L; End = 89L }
                      { Start = 94L; End = 96L }
                      { Start = 97L; End = 98L } ]

                let findSoil = solver part2mapper mappings
                let r = fromRanges seeds
                let ranges = findSoil r
                Expect.equal ranges expectedSoilRanges "full range matches"
            }
        ]
        testList "Ranges" [
            test "Creating ranges" {
                let expectedSeeds = [ { Start = 55; End = 67 }; { Start = 79; End = 92 } ]
                let seeds = [ 79; 14; 55; 13 ]
                let seeds = fromRanges seeds
                Expect.equal seeds expectedSeeds "full range matches"
            }

            test "Overlapping ranges are collapsed" {
                let expectedSeeds = [ { Start = 0L; End = 99L } ]
                let seeds = [ 50L; 25L; 0L; 30L; 25L; 50L; 60L; 40L ]
                let seeds = fromRanges seeds
                Expect.equal seeds expectedSeeds "full range matches"
            }
            test "Leaves non-overlapped ranges alone" {
                let expectedRanges =
                    [ { Start = 45; End = 55 }
                      { Start = 78; End = 80 }
                      { Start = 82; End = 85 }
                      { Start = 90; End = 98 } ]

                let ranges = [ 78; 3; 82; 4; 90; 9; 45; 11 ]
                let ranges = fromRanges ranges
                Expect.equal ranges expectedRanges "lists match"
            }
        ]
    ]
