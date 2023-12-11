// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day9

open System.CommandLine
open System.IO

open FSharp.Control
open FSharpx

open Advent2023.CommandLine
open Advent2023.Support


type Report = list<int64>


module Report =
    let init: list<int64> -> Report = id

    let private calcDeltas = List.pairwise >> List.map (uncurry (flip (-)))

    let rec nextValue (r: Report) =
        if List.forall ((=) 0L) r then
            0L
        else
            let deltas = calcDeltas r
            let delta = nextValue deltas
            delta + List.last r

    let prevValue = List.rev >> nextValue


module Parsers =
    open FParsec

    let reports<'a> : Parser<list<Report>, 'a> =
        let report = sepEndBy pint64 (skipMany1 (pchar ' ')) |>> Report.init
        sepEndBy report newline .>> eof


let printReports (console: IConsole) reports =
    let nextValues = List.map Report.nextValue reports
    let sums = nextValues |> List.sum
    console.WriteLine $"Sum of next values: {sums}"

    let prevValues = List.map Report.prevValue reports
    let sums = prevValues |> List.sum
    console.WriteLine $"Sum of prev values: {sums}"


type Options = { Input: FileInfo }

let run (options: Options) (console: IConsole) =
    task {
        return
            runParserOnStream Parsers.reports () options.Input
            |> Result.map (printReports console)
    }

let command = Command.create "day9" "Mirage Maintenance" run
