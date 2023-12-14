// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day13

open System
open System.Collections.Generic
open System.CommandLine

open FSharpx

open Advent2023.CommandLine
open Advent2023.Support


[<Struct>]
type Reflection =
    | Horizontal of h: int64
    | Vertical of v: int64

module Reflection =
    let interpret =
        function
        | Horizontal h -> 100L * h
        | Vertical v -> v


[<Struct>]
type Pattern = Pattern of char[,]

module Pattern =
    let private maybe = FSharpx.Option.maybe

    let init lines =
        let firstLen = lines |> List.head |> String.length
        assert (List.forall (String.length >> ((=) firstLen)) lines)

        let storage = Array2D.zeroCreate firstLen (List.length lines)

        lines
        |> List.iteri (fun y line -> line |> String.iteri (fun x c -> storage[x, y] <- c))

        Pattern storage

    let private intify' =
        Seq.indexed
        >> Seq.mapFold
            (fun table (index, span) ->
                match Map.tryFind span table with
                | Some num -> num, table
                | None -> index, Map.add span index table)
            Map.empty
        >> (fun (seq, map) -> Seq.toArray seq, map)

    let intify = intify' >> fst

    let private isMirrored (lhs: ReadOnlySpan<'a>) (rhs: ReadOnlySpan<'a>) =
        let mutable isMatched = true
        let mutable idx = 0

        while isMatched && idx < lhs.Length do
            isMatched <- isMatched && lhs[idx] = rhs[rhs.Length - idx - 1]
            idx <- idx + 1

        isMatched

    let private findReflection' refType pred arr =
        let arrLen = Array.length arr

        let slices =
            [| for idx in 0 .. arrLen / 2 - 1 do
                   yield (0, idx + 1)
                   yield (arrLen - 2 * (idx + 1), idx + 1) |]

        let span = ReadOnlySpan arr

        let mutable found = None
        let mutable sliceIdx = 0

        while Option.isNone found && sliceIdx < Array.length slices do
            let offset, length = slices[sliceIdx]

            let lhs = span.Slice (offset, length)
            let rhs = span.Slice (offset + length, length)

            let maybeType = offset + length |> int64 |> refType

            if isMirrored lhs rhs && pred maybeType then
                found <- Some maybeType
            else
                sliceIdx <- sliceIdx + 1

        found

    let findReflectionExcluding m (Pattern p) =
        intify (Array2D.rows p)
        |> findReflection' Horizontal ((<>) m)
        |> Option.orElseWith (fun () ->
            intify (Array2D.columns p) |> findReflection' Vertical ((<>) m))
        |> Option.defaultValue (Vertical 0L)

    let findReflection = findReflectionExcluding (Horizontal 0L)

    let fixSmudge (Pattern p) =
        let toggle grid x y =
            Array2D.get grid x y
            |> function
                | '.' -> '#'
                | '#' -> '.'
                | _ -> failwith "pattern has invalid characters"
            |> Array2D.set grid x y

        let original = findReflection (Pattern p)

        let hasNewMirror = findReflectionExcluding original >> ((<>) (Vertical 0L))

        let newGrid = Array2D.copy p

        let points =
            seq {
                for x in 0 .. Array2D.length1 newGrid - 1 do
                    for y in 0 .. Array2D.length2 newGrid - 1 do
                        yield (x, y)
            }

        let rec loop grid (pts: IEnumerator<int * int>) =
            if pts.MoveNext () then
                let x, y = pts.Current
                toggle grid x y

                if hasNewMirror (Pattern grid) then
                    Pattern grid
                else
                    toggle grid x y
                    loop grid pts
            else
                Pattern grid

        points.GetEnumerator () |> loop newGrid


module Parsers =
    open FParsec

    let pattern<'a> : Parser<Pattern, 'a> =
        let cell = choice [ pchar '.'; pchar '#' ]
        let line = many1Chars cell .>> newline
        many line |>> Pattern.init

    let patterns<'a> : Parser<list<Pattern>, 'a> = sepEndBy pattern newline .>> eof


let printNotes (console: IConsole) patterns =
    let sum =
        patterns
        |> List.map (Pattern.findReflection >> Reflection.interpret)
        |> List.sum

    console.WriteLine $"Summary of notes: {sum}"

    let sum =
        patterns
        |> List.map (fun pattern ->
            pattern
            |> Pattern.fixSmudge
            |> Pattern.findReflectionExcluding (Pattern.findReflection pattern)
            |> Reflection.interpret)

    let sum = List.sum sum
    console.WriteLine $"Summary of notes (smudges fixed): {sum}"


let command =
    Command.create "day13" "Point of Incidence" (runSolution printNotes Parsers.patterns)
