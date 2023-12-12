// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day11

open Expecto

open Advent2023.Solutions.Day11

[<Tests>]
let tests =
    testList "Day 11" [
        testList "Examples" [
            let image =
                GalaxyImage [
                    { X = 3L; Y = 0L }
                    { X = 7L; Y = 1L }
                    { X = 0L; Y = 2L }
                    { X = 6L; Y = 4L }
                    { X = 1L; Y = 5L }
                    { X = 9L; Y = 6L }
                    { X = 7L; Y = 8L }
                    { X = 0L; Y = 9L }
                    { X = 4L; Y = 9L }
                ]

            test "Part 1" {
                let expectedSum = 374L
                let sum = image |> GalaxyImage.expand 2L |> GalaxyImage.shortestPaths |> List.sum
                Expect.equal sum expectedSum "sums match"
            }

            testList "Part 2" [
                test "10 times larger" {
                    let expectedSum = 1030L

                    let sum =
                        image |> GalaxyImage.expand 10L |> GalaxyImage.shortestPaths |> List.sum

                    Expect.equal sum expectedSum "sums match"
                }
                test "100 times larger" {
                    let expectedSum = 8410L

                    let sum =
                        image |> GalaxyImage.expand 100L |> GalaxyImage.shortestPaths |> List.sum

                    Expect.equal sum expectedSum "sums match"
                }
            ]
        ]
    ]
