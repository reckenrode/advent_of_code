// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day8

open System.CommandLine
open System.IO

open FParsec.CharParsers
open FSharpx

open Advent2023.CommandLine
open Advent2023.Support


#nowarn "9" // Due to using stack-allocated arrays


[<Struct>]
type Node =
    { Source: string
      Destinations: string * string }

module Node =
    let source n = n.Source
    let destinations n = n.Destinations


[<Struct>]
type GhostMap =
    { Traversals: string
      Network: list<Node> }

module GhostMap =
    let traversals m = m.Traversals
    let network m = m.Network

    let traverse fromNodes toNodes map =
        let indexMapping =
            network map
            |> List.indexed
            |> List.map (fun (idx, node) -> Node.source node, idx)
            |> Map.ofList

        let lookupIndex = flip Map.find indexMapping

        let startNodes = List.map lookupIndex fromNodes
        let endNodes = List.map lookupIndex toNodes |> Set.ofList

        let destinations =
            let traversals =
                traversals map |> Seq.map (fun c -> if c = 'R' then 1 else 0) |> Seq.toList

            let network =
                network map
                |> Seq.collect (fun node ->
                    let leftDest, rightDest = Node.destinations node
                    [ lookupIndex leftDest; lookupIndex rightDest ])
                |> Seq.toArray

            let rec findEndPoint path steps location =
                match path with
                | [] -> steps, location
                | _ when Set.contains location endNodes -> steps, location
                | dir :: path -> findEndPoint path (steps + 1L) (network[2 * location + dir])

            Seq.init (Map.count indexMapping) id
            |> Seq.map (fun node -> findEndPoint traversals 0L node)
            |> Seq.toArray

        let rec findDistance (arr: array<int64 * int>) =
            if List.forall (fun idx -> Set.contains (snd arr[idx]) endNodes) startNodes then
                startNodes |> List.map (fun idx -> fst arr[idx]) |> List.reduce lcm
            else
                arr
                |> Array.map (fun (steps, node) ->
                    let moreSteps, newEnd = arr[node]
                    steps + moreSteps, newEnd)
                |> findDistance

        findDistance destinations


module Parsers =
    open FParsec

    let traversals<'a> : Parser<string, 'a> =
        many1Chars (choice [ (pchar 'L'); (pchar 'R') ]) .>> newline

    let network<'a> : Parser<list<Node>, 'a> =
        let nodeName = many1Chars upper

        let destination =
            between
                (pchar '(')
                (pchar ')')
                (pipe3 nodeName (pchar ',' .>> spaces) nodeName (fun fst _ snd -> fst, snd))

        let line =
            nodeName .>> spaces .>> pchar '=' .>> spaces .>>. destination
            |>> (fun (src, dest) -> { Source = src; Destinations = dest })

        sepEndBy line newline

    let ghostMap =
        traversals .>> newline .>>. network .>> eof
        |>> (fun (trv, net) -> { Traversals = trv; Network = net })


let printMapTraversals (console: IConsole) map =
    let steps = GhostMap.traverse [ "AAA" ] [ "ZZZ" ] map
    console.WriteLine $"Steps required to reach ZZZ: {steps}"

    let nodesEndingWith s =
        GhostMap.network >> List.map Node.source >> List.filter (String.endsWith s)

    let starts = nodesEndingWith "A" map
    let ends = nodesEndingWith "Z" map
    let steps = GhostMap.traverse starts ends map
    console.WriteLine $"Steps required to read all nodes ending in Z: {steps}"


let command =
    Command.create "day8" "Haunted Wasteland" (runSolution printMapTraversals Parsers.ghostMap)
