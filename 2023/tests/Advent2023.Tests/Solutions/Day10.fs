// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day10

open Expecto
open FParsec

open Advent2023.Solutions.Day10


[<Tests>]
let tests =
    testList "Day 10" [
        testList "Examples" [
            let mazes =
                [ let mkMaze =
                      runParserOnString Parsers.maze () "examples"
                      >> (function
                      | Success (m, _, _) -> m
                      | Failure (m, _, _) -> failwith m)

                  (mkMaze
                      "-L|F7\n\
                    7S-7|\n\
                    L|7||\n\
                    -L-J|\n\
                    L|-JF")

                  (mkMaze
                      "7-F7-\n\
                    .FJ|7\n\
                    SJLL7\n\
                    |F--J\n\
                    LJ.LJ")

                  (mkMaze
                      ".F----7F7F7F7F-7....\n\
                    .|F--7||||||||FJ....\n\
                    .||.FJ||||||||L7....\n\
                    FJL7L7LJLJ||LJ.L-7..\n\
                    L--J.L7...LJS7F-7L7.\n\
                    ....F-J..F7FJ|L7L7L7\n\
                    ....L7.F7||L7|.L7L7|\n\
                    .....|FJLJ|FJ|F7|.LJ\n\
                    ....FJL-7.||.||||...\n\
                    ....L---J.LJ.LJLJ...")

                  (mkMaze
                      "FF7FSF7F7F7F7F7F---7\n\
                    L|LJ||||||||||||F--J\n\
                    FL-7LJLJ||||||LJL-77\n\
                    F--JF--7||LJLJ7F7FJ-\n\
                    L---JF-JLJ.||-FJLJJ7\n\
                    |F|F-JF---7F7-L7L|7|\n\
                    |FFJF7L7F-JF7|JL---7\n\
                    7-L-JL7||F7|L7F-7F7|\n\
                    L.L7LFJ|||||FJL7||LJ\n\
                    L7JLJL-JLJLJL--JLJ.L") ]

            test "Part 1" {
                let expectedDistances = [ 4; 8; 70; 80 ]
                let distances = List.map (Maze.farthestPoint >> (fun struct (fst, _) -> fst)) mazes
                Expect.equal distances expectedDistances "distances match"
            }

            test "Part 2" {
                let expectedCounts = [ 1; 1; 8; 10 ]
                let counts = List.map Maze.countInside mazes
                Expect.equal counts expectedCounts "cells inside match"
            }
        ]
    ]
