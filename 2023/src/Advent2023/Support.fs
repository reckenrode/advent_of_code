// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Support

open System.CommandLine
open System.IO
open System.Numerics
open System.Text

open FParsec
open FSharp.Control


let runParserOnStream parser state (file: FileInfo) =
    use stream = file.OpenRead ()

    runParserOnStream parser state file.Name stream Encoding.UTF8
    |> function
        | Success (result, _, _) -> Result.Ok result
        | Failure (message, _, _) -> Result.Error message

type BasicOptions = { Input: FileInfo }

let runSolution (f: IConsole -> 'a -> unit) p options (console: IConsole) =
    task { return runParserOnStream p () options.Input |> Result.map (f console) }

let rec lines (reader: TextReader) =
    taskSeq {
        match! reader.ReadLineAsync () with
        | null -> ()
        | line ->
            yield line
            yield! lines reader
    }


let inline gcd (lhs: 'a) (rhs: 'a) : 'a :> IBinaryInteger<'a> =
    let zero = 'a.Zero
    let one = 'a.One
    let two = 'a.One + 'a.One

    let rec loop lhs rhs counter =
        if lhs = one && rhs = one then
            one
        elif lhs = rhs then
            lhs * counter
        else
            let struct (lhsQuo, lhsRem) = 'a.DivRem (lhs, two)
            let struct (rhsQuo, rhsRem) = 'a.DivRem (rhs, two)

            match lhsRem = zero, rhsRem = zero with
            | true, true -> loop lhsQuo rhsQuo counter * two
            | true, false -> loop lhsQuo rhs counter
            | false, true -> loop lhs rhsQuo counter
            | false, false when lhs < rhs -> loop rhs lhs counter
            | false, false -> loop (lhs - rhs) rhs counter

    loop lhs rhs 'a.One

let inline lcm lhs rhs =
    let gcd = gcd lhs rhs

    if gcd = rhs || gcd = rhs then
        max lhs rhs
    else
        lhs * rhs / gcd


module Array2D =
    let rows (arr: 'a[,]) =
        seq {
            for row in 0 .. Array2D.length2 arr - 1 do
                yield arr[*, row]
        }


[<Struct>]
type Point = { X: int; Y: int }

module Point =
    let x (pt: Point) = pt.X
    let y (pt: Point) = pt.Y

    let adjacentPoints pt =
        [ { X = pt.X - 1; Y = pt.Y - 1 }
          { X = pt.X; Y = pt.Y - 1 }
          { X = pt.X + 1; Y = pt.Y - 1 }
          { X = pt.X - 1; Y = pt.Y }
          { X = pt.X + 1; Y = pt.Y }
          { X = pt.X - 1; Y = pt.Y + 1 }
          { X = pt.X; Y = pt.Y + 1 }
          { X = pt.X + 1; Y = pt.Y + 1 } ]
