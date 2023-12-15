// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day15

open Expecto

open Advent2023.Solutions.Day15


[<Tests>]
let tests =
    testList "Day 15" [
        testList "Examples" [
            let example =
                [ "rn=1"
                  "cm-"
                  "qp=3"
                  "cm=2"
                  "qp-"
                  "pc=4"
                  "ot=9"
                  "ab=5"
                  "pc-"
                  "pc=6"
                  "ot=7" ]

            test "Part 1" {
                let expectedHashes =
                    [ 30uy; 253uy; 97uy; 47uy; 14uy; 180uy; 9uy; 197uy; 48uy; 214uy; 231uy ]

                let hashes = List.map lavaHash example
                Expect.equal hashes expectedHashes "hashes hashed correctly"
            }

            testList "Part 2" [
                let hashmap =
                    let arr = Array.create 256 []

                    Array.set arr 0 [
                        { Label = "rn"; FocalLength = 1 }
                        { Label = "cm"; FocalLength = 2 }
                    ]

                    Array.set arr 3 [
                        { Label = "ot"; FocalLength = 7 }
                        { Label = "ab"; FocalLength = 5 }
                        { Label = "pc"; FocalLength = 6 }
                    ]

                    HASHMAP arr

                test "Step processing" {
                    let expectedHashmap = hashmap
                    let hashmap = HASHMAP.init example
                    Expect.equal hashmap expectedHashmap "steps processed correctly"
                }

                test "Focusing power" {
                    let expectedPower = 145
                    let focusingPower = HASHMAP.focusingPower hashmap
                    Expect.equal focusingPower expectedPower "focusing power calculated correctly"
                }
            ]
        ]
    ]
