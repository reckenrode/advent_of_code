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


let updateState f =
    FSharpx.State.state {
        let! s = FSharpx.State.getState
        return! FSharpx.State.putState (f s)
    }


module Array2D =
    let columns (arr: 'a[,]) =
        seq {
            for column in 0 .. Array2D.length1 arr - 1 do
                yield arr[column, *]
        }

    let rows (arr: 'a[,]) =
        seq {
            for row in 0 .. Array2D.length2 arr - 1 do
                yield arr[*, row]
        }


module List =
    let rec allPairings =
        function
        | [] -> []
        | x :: xs -> [ yield! List.map (fun y -> (x, y)) xs; yield! allPairings xs ]

    let optionals predicate lst = if predicate then lst else []

[<Struct>]
type Point<'a when IBinaryInteger<'a>> =
    { X: 'a
      Y: 'a }

    interface IAdditionOperators<Point<'a>, Point<'a>, Point<'a>> with
        static member (+) (lhs, rhs) = Point<'a>.(+) (lhs, rhs)
        static member op_CheckedAddition (lhs, rhs) = Point<'a>.op_CheckedAddition (lhs, rhs)

    interface ISubtractionOperators<Point<'a>, Point<'a>, Point<'a>> with
        static member (-) (lhs, rhs) = Point<'a>.(-) (lhs, rhs)
        static member op_CheckedSubtraction (lhs, rhs) = Point<'a>.op_CheckedSubtraction (lhs, rhs)

    static member (+) (lhs, rhs) =
            { X = lhs.X + rhs.X; Y = lhs.Y + rhs.Y }

    static member op_CheckedAddition (lhs, rhs) =
            { X = 'a.op_CheckedAddition (lhs.X, rhs.X)
              Y = 'a.op_CheckedAddition (rhs.Y, rhs.Y) }

    static member (-) (lhs, rhs) =
            { X = lhs.X - rhs.X; Y = lhs.Y - rhs.Y }

    static member op_CheckedSubtraction (lhs, rhs) =
            { X = 'a.op_CheckedSubtraction (lhs.X, rhs.X)
              Y = 'a.op_CheckedSubtraction (rhs.Y, rhs.Y) }

module Point =
    let x = _.X
    let y = _.Y

    let adjacentPoints (pt: Point<'a>) =
        [ { X = pt.X - 'a.One; Y = pt.Y - 'a.One }
          { X = pt.X; Y = pt.Y - 'a.One }
          { X = pt.X + 'a.One; Y = pt.Y - 'a.One }
          { X = pt.X - 'a.One; Y = pt.Y }
          { X = pt.X + 'a.One; Y = pt.Y }
          { X = pt.X - 'a.One; Y = pt.Y + 'a.One }
          { X = pt.X; Y = pt.Y + 'a.One }
          { X = pt.X + 'a.One; Y = pt.Y + 'a.One } ]

    let taxicabDistance (lhs: Point<'a>) (rhs: Point<'a>) =
        'a.Abs (lhs.X - rhs.X) + 'a.Abs (lhs.Y - rhs.Y)

    let zero<'a when IBinaryInteger<'a>> = { X = 'a.Zero; Y = 'a.Zero }
