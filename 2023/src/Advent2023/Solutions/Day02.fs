// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day2

open System.CommandLine
open System.IO

open FSharp.Control

open Advent2023.CommandLine
open Advent2023.Support


type Play =
    { Red: int32
      Green: int32
      Blue: int32 }

module Play =
    let empty = { Red = 0; Green = 0; Blue = 0 }


type Game = list<Play>

module Game =
    let canPlay bag =
        List.forall (fun play ->
            play.Red <= bag.Red && play.Green <= bag.Green && play.Blue <= bag.Blue)

    let calculatePower game =
        let minBag =
            game
            |> List.fold
                (fun acc play ->
                    { Red = max acc.Red play.Red
                      Green = max acc.Green play.Green
                      Blue = max acc.Blue play.Blue })
                Play.empty

        minBag.Red * minBag.Green * minBag.Blue


    let filterValidGames bag =
        List.mapi (fun idx game -> idx + 1, game) >> List.filter (snd >> canPlay bag)


module Parsers =
    open FParsec

    let private ofList =
        let rec ofList' play =
            function
            | [] -> Some play
            | (digit, label) :: xs ->
                match label with
                | "red" when play.Red = 0 -> ofList' { play with Red = digit } xs
                | "green" when play.Green = 0 -> ofList' { play with Green = digit } xs
                | "blue" when play.Blue = 0 -> ofList' { play with Blue = digit } xs
                | _ -> None

        ofList' Play.empty

    let play<'a> : Parser<Play, 'a> =
        let red = pstring "red"
        let green = pstring "green"
        let blue = pstring "blue"
        let color = choice [ attempt red; attempt green; blue ]
        let set = pint32 .>> spaces1 .>>. color
        let play = sepBy set (pstring ", ")

        play
        >>= (fun colors ->
            match ofList colors with
            | Some play -> preturn play
            | None -> fail "invalid play")

    let game<'a> : Parser<Game, 'a> =
        let header = pstring "Game" >>. spaces1 >>. pint32 .>> pstring ": " |>> ignore
        header >>. sepBy play (pstring "; ")

    let games<'a> : Parser<list<Game>, 'a> = sepBy game newline .>> eof


let printGameInfo bag (console: IConsole) games =
    let validGames = Game.filterValidGames bag games
    let sumIds = validGames |> List.map fst |> List.sum
    let sumPowers = games |> List.map Game.calculatePower |> List.sum

    console.WriteLine $"Sum of the IDs of valid games: {sumIds}"
    console.WriteLine $"Sum of the powers: {sumPowers}"


type Options = { Input: FileInfo }

let run (options: Options) (console: IConsole) =
    task {
        let defaultBag = { Red = 12; Green = 13; Blue = 14 }
        return
            runParserOnStream Parsers.games () options.Input
            |> Result.map (printGameInfo defaultBag console)
    }

let command = Command.create "day2" "Cube Conundrum" run
