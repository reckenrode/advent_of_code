// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day4

open Expecto

open Advent2023.Solutions.Day4
open System


[<Tests>]
let tests =
    testList "Day 4" [
        testList "Examples" [
            let cards =
                [ { Id = 1
                    Winners = [ 41; 48; 83; 86; 17 ]
                    Numbers = set [ 83; 86; 6; 31; 17; 9; 48; 53 ] }
                  { Id = 2
                    Winners = [ 13; 32; 20; 16; 61 ]
                    Numbers = set [ 61; 30; 68; 82; 17; 32; 24; 19 ] }
                  { Id = 3
                    Winners = [ 1; 21; 53; 59; 44 ]
                    Numbers = set [ 69; 82; 63; 72; 16; 21; 14; 1 ] }
                  { Id = 4
                    Winners = [ 41; 92; 73; 84; 69 ]
                    Numbers = set [ 59; 84; 76; 51; 58; 5; 54; 83 ] }
                  { Id = 5
                    Winners = [ 87; 83; 26; 28; 32 ]
                    Numbers = set [ 88; 30; 70; 12; 93; 22; 82; 36 ] }
                  { Id = 6
                    Winners = [ 31; 18; 13; 56; 72 ]
                    Numbers = set [ 74; 77; 10; 23; 35; 67; 36; 11 ] } ]

            test "Part 1" {
                let expectedScores = [ 8; 2; 2; 1; 0; 0 ]
                let scores = List.map Card.score cards
                Expect.equal scores expectedScores "games score correctly"
            }

            test "Part 2" {
                let expectedCardStats = Map [ 1, 1; 2, 2; 3, 4; 4, 8; 5, 14; 6, 1 ]

                let cardStats =
                    Game.play cards
                    |> List.groupBy _.Id
                    |> List.map (fun (k, v) -> k, List.length v)
                    |> Map.ofList

                Expect.equal cardStats expectedCardStats "game played correctly"
            }
        ]
    ]
