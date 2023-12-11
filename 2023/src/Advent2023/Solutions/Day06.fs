// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day6

open System.CommandLine
open System.IO

open FSharpx

open Advent2023.CommandLine
open Advent2023.Support


type RaceResult = { Time: int64; Distance: int64 }

module RaceResult =
    let empty = { Time = 0; Distance = 0 }

    let init t d = { Time = t; Distance = d }

    let countWaysToBeat r =
        let t = float r.Time
        let d = float r.Distance
        let r = sqrt (t ** 2.0 - 4.0 * d)
        let lowest, highest = (t - r) / 2.0, (t + r) / 2.0
        int64 (ceil highest - floor lowest) - 1L


module Parsers =
    open FParsec

    let races =
        let spaces1 = skipMany1 (pchar ' ')
        let timeLine = pstring "Time:" >>. many (spaces1 >>. pint64) .>> newline
        let distLine = pstring "Distance:" >>. many (spaces1 >>. pint64) .>> newline

        pipe2 timeLine distLine List.zip |>> List.map (uncurry RaceResult.init) .>> eof


let printRaceReport (console: IConsole) results =
    let part1 = results |> List.map RaceResult.countWaysToBeat |> List.fold (*) 1L
    console.WriteLine $"Ways to win (multiplied together): {part1}"

    let part2Time, part2Dist =
        results
        |> List.fold (fun (t, d) r -> $"{t}{r.Time}", $"{d}{r.Distance}") ("", "")

    let part2 =
        RaceResult.init (int64 part2Time) (int64 part2Dist)
        |> RaceResult.countWaysToBeat

    console.WriteLine $"Ways to win (multiplied together): {part2}"


type Options = { Input: FileInfo }

let run (options: Options) (console: IConsole) =
    task {
        return
            runParserOnStream Parsers.races () options.Input
            |> Result.map (printRaceReport console)
    }

let command = Command.create "day6" "Wait For It" run
