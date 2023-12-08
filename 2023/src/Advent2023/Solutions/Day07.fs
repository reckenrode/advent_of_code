// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day7

open System
open System.CommandLine
open System.IO

open FSharpx

open Advent2023.Support


[<Struct>]
type Card = private Card of uint8

module Card =
    let parse =
        function
        | s when s >= "2" && s <= "9" -> Option.map Card (Byte.parse s)
        | "T" -> Some (Card 10uy)
        | "J" -> Some (Card 11uy)
        | "Q" -> Some (Card 12uy)
        | "K" -> Some (Card 13uy)
        | "A" -> Some (Card 14uy)
        | _ -> None


[<Struct; CustomComparison; CustomEquality>]
type HandType =
    | SameKind of kind: uint
    | FullHouse
    | TwoPair of pairs: struct (Card * Card)
    | HighCard of card: Card

    interface IComparable<HandType> with
        member this.CompareTo other =
            match this, other with
            | SameKind lhs, SameKind rhs -> compare lhs rhs
            | FullHouse, FullHouse -> 0
            | FullHouse, SameKind rhs when rhs < 4u -> 1
            | FullHouse, SameKind rhs when rhs >= 4u -> -1
            | FullHouse, _ -> 1
            | SameKind lhs, FullHouse when lhs < 4u -> -1
            | SameKind lhs, FullHouse when lhs >= 4u -> 1
            | _, FullHouse -> -1
            | TwoPair _, TwoPair _ -> 0
            | TwoPair _, SameKind rhs when rhs < 3u -> 1
            | TwoPair _, SameKind rhs when rhs >= 3u -> -1
            | TwoPair _, _ -> 1
            | SameKind lhs, TwoPair _ when lhs < 3u -> -1
            | SameKind lhs, TwoPair _ when lhs >= 3u -> 1
            | _, TwoPair _ -> -1
            | HighCard _, HighCard _ -> 0
            | _, HighCard _ -> 1
            | HighCard _, _ -> -1

    interface IComparable with
        member this.CompareTo other =
            match other with
            | :? HandType as other -> (this :> IComparable<_>).CompareTo other
            | _ -> raise <| ArgumentException $"Object must be of type HandType"

    interface IEquatable<HandType> with
        member this.Equals other = compare this other = 0

    override this.Equals (other: obj) =
        match other with
        | :? HandType as other -> (this :> IEquatable<_>).Equals other
        | _ -> raise <| ArgumentException $"Object must be of type HandType"

    override this.GetHashCode () =
        match this with
        | SameKind k -> hash k
        | FullHouse -> hash 42
        | TwoPair (p1, p2) -> hash (p1, p2)
        | HighCard c -> hash c


[<Struct; CustomComparison; CustomEquality>]
type Hand =
    { Cards: Card * Card * Card * Card * Card
      JokerMode: bool }

    member this.Type () =
        let a, b, c, d, e = this.Cards

        let processJokers jokerMode lst =
            if jokerMode then
                let joker, others = List.partition (fun (_, c) -> c = Card 11uy) lst

                match List.tryHead joker, List.sortDescending others with
                | Some (n, _), (maxN, max) :: rest -> (maxN + n, max) :: rest
                | Some (n, _), [] -> lst
                | None, _ -> lst
            else
                lst

        let groups =
            [ a; b; c; d; e ]
            |> List.groupBy id
            |> List.map (fun (x, xs) -> List.length xs, x)
            |> processJokers this.JokerMode
            |> List.sortBy fst

        match groups with
        | [ (5, _) ] -> SameKind 5u
        | [ _; (4, _) ] -> SameKind 4u
        | [ (2, _); (3, _) ] -> FullHouse
        | [ _; _; (3, _) ] -> SameKind 3u
        | [ _; (2, c1); (2, c2) ] -> TwoPair (c1, c2)
        | [ _; _; _; (2, _) ] -> SameKind 2u
        | xs -> HighCard (xs |> List.sortByDescending snd |> List.head |> snd)

    interface IComparable<Hand> with
        member this.CompareTo other =
            let mapJoker c = if c = Card 11uy then Card 0uy else c

            let mapCards (a, b, c, d, e) =
                mapJoker a, mapJoker b, mapJoker c, mapJoker d, mapJoker e

            let lhsType, rhsType = this.Type (), other.Type ()
            let result = compare lhsType rhsType

            if result = 0 then
                let lhs = if this.JokerMode then mapCards this.Cards else this.Cards

                let rhs =
                    if other.JokerMode then
                        mapCards other.Cards
                    else
                        other.Cards

                compare lhs rhs
            else
                result

    interface IComparable with
        member this.CompareTo other =
            match other with
            | :? Hand as other -> (this :> IComparable<_>).CompareTo other
            | _ -> raise <| ArgumentException $"Object must be of type Hand"

    interface IEquatable<Hand> with
        member this.Equals other = compare this other = 0

    override this.Equals (other: obj) =
        match other with
        | :? Hand as other -> (this :> IEquatable<_>).Equals other
        | _ -> raise <| ArgumentException $"Object must be of type Hand"

    override this.GetHashCode () = hash this.Cards

module rec Hand =
    let private maybe = FSharpx.Option.maybe

    let init a b c d e =
        { Cards = a, b, c, d, e
          JokerMode = false }

    let parse =
        function
        | s when String.length s = 5 ->
            maybe {
                let! a = Card.parse (string s[0])
                let! b = Card.parse (string s[1])
                let! c = Card.parse (string s[2])
                let! d = Card.parse (string s[3])
                let! e = Card.parse (string s[4])
                return Hand.init a b c d e
            }
        | _ -> None

    let ``type`` (hand: Hand) = hand.Type ()

[<Struct>]
type Play = { Hand: Hand; Bid: int64 }

module Play =
    let init h b = { Hand = h; Bid = b }

type Game = list<Play>

module Game =
    let rank = List.sort

    let calculateWinnings =
        List.indexed
        >> List.fold (fun acc (idx, play) -> acc + int64 (idx + 1) * play.Bid) 0L

    let enableJokerMode = List.map (fun p -> { p with Play.Hand.JokerMode = true })

module Parsers =
    open FParsec

    let hand<'a> : Parser<Hand, 'a> =
        manyChars (choice [ letter; digit ])
        >>= (fun s ->
            match Hand.parse s with
            | Some h -> preturn h
            | None -> fail "expected hand of cards")

    let bid = pint64

    let play<'a> : Parser<Play, 'a> = hand .>> spaces1 .>>. bid |>> (uncurry Play.init)

    let game<'a> : Parser<list<Play>, 'a> = sepEndBy play newline .>> eof


let printGameReport game (console: IConsole) =
    let ranking = Game.rank game
    let winnings = Game.calculateWinnings ranking
    console.WriteLine $"Total winnings: {winnings}"

    let ranking = Game.rank (Game.enableJokerMode game)
    let winnings = Game.calculateWinnings ranking
    console.WriteLine $"Total winnings (with jokers): {winnings}"
    0


type Options = { Input: FileInfo }

let run (options: Options) (console: IConsole) =
    task {
        let parsedInput =
            options.Input |> runParserOnStream Parsers.game () |> ParserResult.toResult

        return
            match parsedInput with
            | Result.Ok game -> console |> printGameReport game
            | Result.Error message -> console |> printErrorAndExit message 1
    }

let command = Command.create "day7" "Camel Cards" run
