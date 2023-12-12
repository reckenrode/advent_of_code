// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day11

open System.CommandLine

open FSharpx

open Advent2023.CommandLine
open Advent2023.Support


type GalaxyImage = GalaxyImage of list<Point<int64>>

module GalaxyImage =
    let shortestPaths (GalaxyImage image) =
        image |> List.allPairings |> List.map (uncurry Point.taxicabDistance)

    let expand n (GalaxyImage image) =
        let findGaps (projection: 'point -> int64) =
            List.map projection
            >> List.sort
            >> List.distinct
            >> List.pairwise
            >> List.collect (fun (fst, snd) ->
                List.init (int (snd - fst) - 1) (fun x -> fst + int64 x + 1L))

        let hgaps = findGaps (fun pt -> pt.Y) image
        let vgaps = findGaps (fun pt -> pt.X) image

        let update p a g = if g < p then a + n - 1L else a

        let grow =
            List.map (fun pt ->
                { X = List.fold (update pt.X) pt.X vgaps
                  Y = List.fold (update pt.Y) pt.Y hgaps })

        let newImg = grow image
        GalaxyImage newImg


module Parsers =
    open FParsec

    let image<'a> : Parser<GalaxyImage, 'a> =
        let point (stream: CharStream<_>) =
            Reply
                { X = stream.Column - 1L
                  Y = stream.Line - 1L }

        let empty = pchar '.'
        let galaxy = pchar '#' >>= (fun _ -> point)
        let line = skipMany empty >>. many (galaxy .>> skipMany empty)
        let image = sepBy line newline |>> (List.collect id >> GalaxyImage)
        image .>> eof


let printGalaxyInfo (console: IConsole) galaxy =
    let sum = galaxy |> GalaxyImage.expand 2L |> GalaxyImage.shortestPaths |> List.sum
    console.WriteLine $"Sum of shortest paths (2× expansion): {sum}"

    let sum =
        galaxy |> GalaxyImage.expand 1_000_000L |> GalaxyImage.shortestPaths |> List.sum

    console.WriteLine $"Sum of shortest paths (1000000× expansion): {sum}"


let command =
    Command.create "day11" "Cosmic Expansion" (runSolution printGalaxyInfo Parsers.image)
