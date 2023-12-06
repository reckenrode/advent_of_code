// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day5

open System.CommandLine
open System.IO
open System.Numerics

open FSharp.Control
open FSharpx
open FSharpx.Prelude

open Advent2023.Support


let private order =
    [ "seed-to-soil"
      "soil-to-fertilizer"
      "fertilizer-to-water"
      "water-to-light"
      "light-to-temperature"
      "temperature-to-humidity"
      "humidity-to-location" ]


[<Struct>]
type Range<'a> when 'a :> IBinaryInteger<'a> = { Start: 'a; End: 'a }

module Range =
    let inline ofList<'a when 'a :> IBinaryInteger<'a>> =
        function
        | [ start; length ] ->
            Some
                { Start = start
                  End = start + length - 'a.One }
        | _ -> None

    let inline split (other: Range<'a>) =
        function
        | r when r.Start > other.End || r.End < other.Start ->
            struct {| Inner = None; Outer = [ r ] |}
        | r when r.Start >= other.Start && r.End <= other.End ->
            struct {| Inner = Some r; Outer = [] |}
        | r when r.Start < other.Start && r.End <= other.End ->
            struct {| Inner = Some { other with End = r.End }
                      Outer = [ { r with End = other.Start - 'a.One } ] |}
        | r when r.Start < other.Start && r.End > other.End ->
            struct {| Inner = Some other
                      Outer =
                       [ { r with End = other.Start - 'a.One }
                         { r with Start = other.End + 'a.One } ] |}
        | r when r.Start >= other.Start && r.End > other.End ->
            struct {| Inner = Some { other with Start = r.Start }
                      Outer = [ { r with Start = other.End + 'a.One } ] |}
        | _ -> failwith "This shouldn’t happen"


let private optimize lst =
    let rec optimize' visited =
        function
        | seed1 :: seed2 :: xs when seed1.End >= seed2.Start ->
            optimize' visited ({ Start = seed1.Start; End = seed2.End } :: xs)
        | x :: xs -> optimize' (x :: visited) xs
        | [] -> List.rev visited

    optimize' [] (List.sort lst)

let fromRanges lst =
    lst |> List.chunkBySize 2 |> List.choose Range.ofList |> optimize

let solver mapper mappings =
    let pipeline =
        order
        |> List.map (flip Map.tryFind mappings >> Option.map mapper)
        |> List.choose id

    if List.length pipeline <> List.length order then
        failwith "Input mappings do not contain every required stage"

    let rec solver' pipeline values =
        match pipeline with
        | [] -> values
        | f :: fs -> solver' fs (f values)

    solver' pipeline

let part1mapper mapping =
    let mapping =
        mapping
        |> List.map (fun (destStart, sourceStart, rangeLength) ->
            let sourceEnd = sourceStart + rangeLength - 1L

            fun x ->
                if x < sourceStart || x > sourceEnd then
                    None
                else
                    Some (x - sourceStart + destStart))

    fun source -> mapping |> List.tryPick (fun f -> f source) |> Option.defaultValue source

let part2mapper mapping =
    let mapping =
        mapping
        |> List.map (fun (destStart, sourceStart, rangeLength) ->
            let source =
                { Start = sourceStart
                  End = sourceStart + rangeLength - 1L }

            let delta = destStart - sourceStart

            fun x ->
                let result = Range.split source x

                {| result with
                    Inner =
                        result.Inner
                        |> Option.map (fun mapped ->
                            { Start = mapped.Start + delta
                              End = mapped.End + delta }) |})

    fun source ->
        let mapped, unmapped =
            mapping
            |> List.fold
                (fun (mapped, unmapped) f ->
                    let raw = List.map f unmapped
                    let extraMapped = raw |> List.choose (fun x -> x.Inner)
                    let unmapped = raw |> List.collect (fun x -> x.Outer)
                    extraMapped @ mapped, unmapped)
                ([], source)

        optimize (mapped @ unmapped)

module Parsers =
    open FParsec

    let almanac =
        let many1Spaces = many1Chars (pchar ' ')
        let seeds = pstring "seeds: " >>. sepBy pint64 many1Spaces .>> newline

        let header = manyCharsTill anyChar (pchar ' ') .>> pstring "map:" .>> newline

        let mapping =
            pipe3 (pint64 .>> many1Spaces) (pint64 .>> many1Spaces) pint64 Prelude.tuple3
            .>> newline

        let mappingBlock = header .>>. many mapping

        seeds .>> newline .>>. (sepBy mappingBlock newline |>> Map.ofList) .>> eof

let printSoilReport mappings seeds (console: IConsole) =
    let part1solver = solver part1mapper mappings
    let lowestPart1 = seeds |> List.map part1solver |> List.min
    console.WriteLine $"Lowest location number for any seed in part 1: {lowestPart1}"

    let part2solver = solver part2mapper mappings
    let lowestPart2 = part2solver (fromRanges seeds) |> List.head
    console.WriteLine $"Lowest location number for any seed in part 2: {lowestPart2.Start}"

    0

type Options = { Input: FileInfo }

let run (options: Options) (console: IConsole) =
    task {
        use file = options.Input.OpenRead ()

        let parsedInput =
            options.Input |> runParserOnStream Parsers.almanac () |> ParserResult.toResult

        return
            match parsedInput with
            | Ok (seeds, mappings) -> console |> printSoilReport mappings seeds
            | Error message -> console |> printErrorAndExit message 1
    }

let command = Command.create "day5" "If You Give A Seed A Fertilizer" run
