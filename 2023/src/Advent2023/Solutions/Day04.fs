// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day4

open System.CommandLine
open System.IO

open FSharp.Control

open Advent2023.CommandLine
open Advent2023.Support


type Card =
    { Id: int32
      Winners: Set<int32>
      Numbers: Set<int32> }

module Card =
    let matches c = Set.intersect c.Winners c.Numbers

    let score = matches >> Set.count >> ((+) -1) >> ((<<<) 1) >> (max 0)


type Game = list<Card>

module Game =
    let play g =
        let template = g |> List.map (fun c -> c.Id, c) |> Map.ofList

        let clone id numCopies =
            [ for maybeId in id + 1 .. id + numCopies do
                  match Map.tryFind maybeId template with
                  | Some card -> yield card
                  | None -> () ]

        let rec play' visited =
            function
            | [] -> List.rev visited
            | c :: cs ->
                let qty = Card.matches c |> Set.count
                let extraCopies = clone c.Id qty
                play' (c :: visited) (extraCopies @ cs)

        play' [] g

module Parsers =
    open FParsec

    let card<'a> : Parser<Card, 'a> =
        let header = pstring "Card" >>. spaces1 >>. pint32 .>> pchar ':'

        let winners = sepEndBy pint32 spaces1 |>> set
        let numbers = sepBy pint32 spaces1 |>> set

        header .>> spaces1 .>>. winners .>> pchar '|' .>> spaces .>>. numbers
        |>> (fun ((name, winners), numbers) ->
            { Id = name
              Winners = winners
              Numbers = numbers })

    let game<'a> : Parser<Game, 'a> = sepBy card newline .>> eof


let printGameInfo (console: IConsole) game =
    let totalPoints = game |> List.map Card.score |> List.sum
    console.WriteLine $"Total points for part 1: {totalPoints}"

    let played = Game.play game
    console.WriteLine $"Total number of cards played in part 2: {List.length played}"


type Options = { Input: FileInfo }

let run (options: Options) (console: IConsole) =
    task {
        return
            runParserOnStream Parsers.game () options.Input
            |> Result.map (printGameInfo console)
    }

let command = Command.create "day4" "Scratchcards" run
