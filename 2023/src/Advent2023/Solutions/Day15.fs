// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day15

open System
open System.CommandLine
open type System.Text.Encoding


open Advent2023.CommandLine
open Advent2023.Support


let rec private lavaHash' (it: byref<ReadOnlySpan<_>.Enumerator>) accum =
    if it.MoveNext () then
        lavaHash' &it ((accum + it.Current) * 17uy)
    else
        accum

let lavaHash (s: string) =
    let span = ReadOnlySpan (ASCII.GetBytes s)
    let mutable it = span.GetEnumerator ()
    lavaHash' &it 0uy


type Lens = { Label: string; FocalLength: int }

type Op =
    | Add of Lens
    | Remove of string

module Op =
    open FParsec

    let label =
        function
        | Add lens -> lens.Label
        | Remove label -> label

    let parse s =
        let add =
            pipe2 (many1CharsTill letter (pchar '=')) pint32 (fun l n ->
                Add { Label = l; FocalLength = n })

        let rm = many1CharsTill letter (pchar '-') |>> Remove
        let op = attempt add <|> rm

        match runParserOnString op () "op parser" s with
        | Success (result, _, _) -> Some result
        | _ -> None

type HASHMAP = HASHMAP of array<list<Lens>>

module HASHMAP =
    let rec private addToList lens =
        function
        | [] -> lens :: []
        | l :: ls when l.Label = lens.Label -> lens :: ls
        | l :: ls -> l :: addToList lens ls

    let private removeFromList lens = List.filter (_.Label >> (<>) lens)

    let private updateBucket op storage =
        let bucket = Op.label op |> lavaHash |> int32
        let lenses = Array.get storage bucket

        match op with
        | Add lens -> addToList lens lenses
        | Remove lens -> removeFromList lens lenses
        |> Array.set storage bucket

    let init =
        List.fold
            (fun storage rawOp ->
                match Op.parse rawOp with
                | Some cmd -> updateBucket cmd storage
                | None -> failwith $"invalid operation {rawOp} encountered"

                storage)
            (Array.create 256 [])
        >> HASHMAP

    let focusingPower (HASHMAP h) =
        h
        |> Seq.indexed
        |> Seq.filter (snd >> List.isEmpty >> not)
        |> Seq.map (fun (box, xs) ->
            xs |> List.mapi (fun slot lens -> (box + 1) * (slot + 1) * lens.FocalLength))
        |> Seq.concat
        |> Seq.sum


module Parsers =
    open FParsec

    let initSequence<'a> : Parser<list<string>, 'a> =
        let step = manyChars (noneOf [ '\n'; ',' ])
        sepBy1 step (pchar ',')


let printHashResults (console: IConsole) initSequence =
    let hashResults = List.map (lavaHash >> uint) initSequence
    let sum = List.sum hashResults
    console.WriteLine $"Sum of the hash results: {sum}"

    let hashmap = HASHMAP.init initSequence
    let power = HASHMAP.focusingPower hashmap
    console.WriteLine $"Focusing power of the lens configuration: {power}"


let command =
    Command.create "day15" "Lens Library" (runSolution printHashResults Parsers.initSequence)
