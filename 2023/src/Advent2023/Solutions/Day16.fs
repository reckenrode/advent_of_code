// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day16

open System
open System.CommandLine

open FSharpx

open Advent2023.CommandLine
open Advent2023.Support


[<Struct>]
type Direction =
    | Up
    | Down
    | Left
    | Right

module Direction =
    let next d pt =
        match d with
        | Up -> { pt with Y = pt.Y - 1 }
        | Down -> { pt with Y = pt.Y + 1 }
        | Left -> { pt with X = pt.X - 1 }
        | Right -> { pt with X = pt.X + 1 }

    let rotateRight =
        function
        | Up -> Right
        | Right -> Down
        | Down -> Left
        | Left -> Up

    let rotateLeft =
        function
        | Up -> Left
        | Left -> Down
        | Down -> Right
        | Right -> Up

[<Struct>]
type Beam =
    { Position: Point<int>
      Direction: Direction }

module Beam =
    let direction = _.Direction

    let position = _.Position

    let move b =
        { b with
            Position = Direction.next b.Direction b.Position }

type TileType =
    | Energized = '#'
    | MirrorDownLeftTopRight = '/'
    | MirrorTopLeftDownRight = '\\'
    | SplitterHorizontal = '-'
    | SplitterVertical = '|'
    | Empty = '.'


[<Struct>]
type Tiles = private Tiles of struct (TileType * bool)[,]

module Tiles =
    let private state = State.state

    let private chEnum<'a when 'a: enum<char>> =
        FSharp.Core.LanguagePrimitives.EnumOfValue<char, 'a>

    let init xs =
        let firstLen = xs |> List.head |> String.length
        assert (List.forall (String.length >> ((=) firstLen)) xs)

        let storage =
            Array2D.create firstLen (List.length xs) struct (chEnum<TileType> '.', false)

        xs
        |> List.iteri (fun y ->
            String.iteri (fun x ->
                function
                | '-'
                | '|'
                | '/'
                | '\\' as c -> Array2D.set storage x y struct (chEnum<TileType> c, false)
                | '.' -> ()
                | _ -> failwith "invalid tile character"))

        Tiles storage

    let width (Tiles t) = Array2D.length1 t

    let height (Tiles t) = Array2D.length2 t

    let private energize (Tiles t) pt =
        let struct (tile, _) = Array2D.get t pt.X pt.Y
        Array2D.set t pt.X pt.Y struct (tile, true)

    let private reflect (Tiles t) b =
        match Array2D.get t b.Position.X b.Position.Y, b.Direction with
        | struct (TileType.MirrorDownLeftTopRight, _), Up
        | struct (TileType.MirrorDownLeftTopRight, _), Down
        | struct (TileType.MirrorTopLeftDownRight, _), Left
        | struct (TileType.MirrorTopLeftDownRight, _), Right ->
            [ { b with
                  Direction = Direction.rotateRight b.Direction } ]
        | struct (TileType.MirrorTopLeftDownRight, _), Up
        | struct (TileType.MirrorTopLeftDownRight, _), Down
        | struct (TileType.MirrorDownLeftTopRight, _), Left
        | struct (TileType.MirrorDownLeftTopRight, _), Right ->
            [ { b with
                  Direction = Direction.rotateLeft b.Direction } ]
        | struct (TileType.SplitterHorizontal, _), Up
        | struct (TileType.SplitterHorizontal, _), Down ->
            [ { b with Direction = Left }; { b with Direction = Right } ]
        | struct (TileType.SplitterVertical, _), Left
        | struct (TileType.SplitterVertical, _), Right ->
            [ { b with Direction = Up }; { b with Direction = Down } ]
        | _ -> [ b ]

    let private isInBounds tiles pt =
        pt.X >= 0 && pt.X < width tiles && pt.Y >= 0 && pt.Y < height tiles

    let shoot b (Tiles tiles) =
        let rec shoot' bs tiles =
            state {
                let! seenBeams = State.getState

                let newBeams =
                    bs
                    |> List.filter (fun x ->
                        isInBounds tiles x.Position && not (Set.contains x seenBeams))

                do! updateState (flip (List.fold (flip Set.add)) newBeams)

                List.iter (Beam.position >> energize tiles) newBeams
                let newBeams = newBeams |> List.collect (reflect tiles) |> List.map Beam.move

                if not (List.isEmpty newBeams) then
                    return! shoot' newBeams tiles
            }


        let newTiles = Tiles (Array2D.copy tiles)
        State.eval (shoot' [ b ] newTiles) Set.empty
        newTiles

    let energized (Tiles tiles) =
        Array2D.rows tiles
        |> Seq.map (
            Array.map (fun struct (_, isEnergized) -> if isEnergized then '#' else '.')
            >> System.String
        )
        |> Seq.toList

    let count tileType (Tiles tiles) =
        let proj =
            if tileType = TileType.Energized then
                (fun struct (t, x) -> if x then TileType.Energized else t)
            else
                (fun struct (t, _) -> t)

        Array2D.rows tiles
        |> Seq.map (Array.map (fun x -> if proj x = tileType then 1 else 0) >> Array.sum)
        |> Seq.sum


module Parsers =
    open FParsec

    let tile<'a> : Parser<char, 'a> =
        choice [ pchar '.'; pchar '/'; pchar '\\'; pchar '|'; pchar '-' ]

    let tiles<'a> : Parser<Tiles, 'a> =
        let line = many1Chars tile .>> newline
        many line .>> eof |>> Tiles.init


let printResult (console: IConsole) tiles =
    Tiles.energized tiles |> List.iter console.WriteLine
    console.WriteLine $"Tiles energized: {Tiles.count TileType.Energized tiles}"

let printBeamResults (console: IConsole) tiles =
    let result =
        Tiles.shoot
            { Position = { X = 0; Y = 0 }
              Direction = Right }
            tiles

    printResult console result

    let initialBeams =
        [| for x in 0 .. Tiles.width tiles - 1 do
               yield
                   { Position = { X = x; Y = 0 }
                     Direction = Down }

               yield
                   { Position = { X = x; Y = Tiles.height tiles - 1 }
                     Direction = Up }
           for y in 0 .. Tiles.height tiles - 1 do
               yield
                   { Position = { X = 0; Y = y }
                     Direction = Right }

               yield
                   { Position = { X = Tiles.width tiles - 1; Y = y }
                     Direction = Left } |]

    let results =
        initialBeams
        |> Seq.chunkBySize Environment.ProcessorCount
        |> Seq.collect (Array.Parallel.map (flip Tiles.shoot tiles))

    let best = results |> Seq.maxBy (Tiles.count TileType.Energized)
    printResult console best

let command =
    Command.create "day16" "The Floor Will Be Lava" (runSolution printBeamResults Parsers.tiles)
