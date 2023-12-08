// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day7

open Expecto

open Advent2023.Solutions.Day7


[<Tests>]
let tests =
    testList "Day 7" [
        testList "Examples" [
            let plays =
                [ { Hand = Hand.parse "32T3K" |> Option.get
                    Bid = 765L }
                  { Hand = Hand.parse "T55J5" |> Option.get
                    Bid = 684L }
                  { Hand = Hand.parse "KK677" |> Option.get
                    Bid = 28L }
                  { Hand = Hand.parse "KTJJT" |> Option.get
                    Bid = 220L }
                  { Hand = Hand.parse "QQQJA" |> Option.get
                    Bid = 483L } ]

            test "Part 1" {
                let expectedResults =
                    [ { Hand = Hand.parse "32T3K" |> Option.get
                        Bid = 765L }
                      { Hand = Hand.parse "KTJJT" |> Option.get
                        Bid = 220L }
                      { Hand = Hand.parse "KK677" |> Option.get
                        Bid = 28L }
                      { Hand = Hand.parse "T55J5" |> Option.get
                        Bid = 684L }
                      { Hand = Hand.parse "QQQJA" |> Option.get
                        Bid = 483L } ]

                let results = List.sort plays
                Expect.equal results expectedResults "plays are ordered"
            }

            test "Part 2" {
                let expectedResults =
                    [ { Hand = Hand.parse "32T3K" |> Option.get
                        Bid = 765L }
                      { Hand = Hand.parse "KK677" |> Option.get
                        Bid = 28L }
                      { Hand = Hand.parse "T55J5" |> Option.get
                        Bid = 684L }
                      { Hand = Hand.parse "QQQJA" |> Option.get
                        Bid = 483L }
                      { Hand = Hand.parse "KTJJT" |> Option.get
                        Bid = 220L } ]
                    |> Game.enableJokerMode

                let results = Game.rank (Game.enableJokerMode plays)
                Expect.equal results expectedResults "plays are ordered"
            }
        ]

        // From https://www.reddit.com/r/adventofcode/comments/18cr4xr/2023_day_7_better_example_input_not_a_spoiler/
        testList "Reddit Example" [
            let plays =
                [ { Hand = Hand.parse "2345A" |> Option.get
                    Bid = 1L }
                  { Hand = Hand.parse "Q2KJJ" |> Option.get
                    Bid = 13L }
                  { Hand = Hand.parse "Q2Q2Q" |> Option.get
                    Bid = 19L }
                  { Hand = Hand.parse "T3T3J" |> Option.get
                    Bid = 17L }
                  { Hand = Hand.parse "T3Q33" |> Option.get
                    Bid = 11L }
                  { Hand = Hand.parse "2345J" |> Option.get
                    Bid = 3L }
                  { Hand = Hand.parse "J345A" |> Option.get
                    Bid = 2L }
                  { Hand = Hand.parse "32T3K" |> Option.get
                    Bid = 5L }
                  { Hand = Hand.parse "T55J5" |> Option.get
                    Bid = 29L }
                  { Hand = Hand.parse "KK677" |> Option.get
                    Bid = 7L }
                  { Hand = Hand.parse "KTJJT" |> Option.get
                    Bid = 34L }
                  { Hand = Hand.parse "QQQJA" |> Option.get
                    Bid = 31L }
                  { Hand = Hand.parse "JJJJJ" |> Option.get
                    Bid = 37L }
                  { Hand = Hand.parse "JAAAA" |> Option.get
                    Bid = 43L }
                  { Hand = Hand.parse "AAAAJ" |> Option.get
                    Bid = 59L }
                  { Hand = Hand.parse "AAAAA" |> Option.get
                    Bid = 61L }
                  { Hand = Hand.parse "2AAAA" |> Option.get
                    Bid = 23L }
                  { Hand = Hand.parse "2JJJJ" |> Option.get
                    Bid = 53L }
                  { Hand = Hand.parse "JJJJ2" |> Option.get
                    Bid = 41L } ]

            test "Part 1" {
                let expectedWinnings = 6592
                let winnings = plays |> Game.rank |> Game.calculateWinnings
                Expect.equal winnings expectedWinnings "winnings match"
            }

            test "Part 2" {
                let expectedWinnings = 6839
                let winnings = plays |> Game.enableJokerMode |> Game.rank |> Game.calculateWinnings
                Expect.equal winnings expectedWinnings "winnings match"
            }
        ]

        testList "Card ordering" [
            test "Four of a kind" {
                let lhs = Hand.parse "33332" |> Option.get
                let rhs = Hand.parse "2AAAA" |> Option.get
                Expect.isTrue (lhs > rhs) "33332 is stronger"
            }

            test "Full house" {
                let lhs = Hand.parse "77888" |> Option.get
                let rhs = Hand.parse "77788" |> Option.get
                Expect.isTrue (lhs > rhs) "77888 is stronger"
            }
        ]
    ]
