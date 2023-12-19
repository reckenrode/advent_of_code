// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day17

open System
open System.Collections.Generic

open System.CommandLine
open System.IO
open FSharpx

open Advent2023.CommandLine
open Advent2023.Support


[<Struct>]
type Direction =
    | Up
    | Down
    | Left
    | Right
    | None

module Direction =
    let next d pt =
        match d with
        | Up -> { pt with Y = pt.Y - 1 }
        | Down -> { pt with Y = pt.Y + 1 }
        | Left -> { pt with X = pt.X - 1 }
        | Right -> { pt with X = pt.X + 1 }
        | None -> pt

    let rotateRight =
        function
        | Up -> Right
        | Right -> Down
        | Down -> Left
        | Left -> Up
        | None -> None

    let rotateLeft =
        function
        | Up -> Left
        | Left -> Down
        | Down -> Right
        | Right -> Up
        | None -> None


[<Struct>]
type Crucible =
    { Position: Point<int>
      Direction: Direction
      Traveled: int }


[<Struct>]
type CityMap = private CityMap of int64[,]

module CityMap =
    let private state = State.state
    let private maybe = Option.maybe

    let init xs =
        let firstLen = xs |> List.head |> List.length
        assert (List.forall (List.length >> ((=) firstLen)) xs)

        let storage = Array2D.create firstLen (List.length xs) 0L
        xs |> List.iteri (fun y -> List.iteri (fun x value -> storage[x, y] <- value))

        CityMap storage

    let width (CityMap m) = Array2D.length1 m

    let height (CityMap m) = Array2D.length2 m

    let heatLoss (CityMap m) pt = Array2D.get m pt.X pt.Y

    let private distanceTo c =
        Map.tryFind c >> Option.defaultValue Int64.MaxValue

    let private predecessorTo c = Map.tryFind c >> Option.defaultValue c

    [<Struct>]
    type CrucibleProperties =
        { MinForward: int
          MaxForward: int
          StoppingDistance: int }

    let leastHeatLoss props cm =
        let neighbors c =
            List.optionals (c.Traveled < props.MaxForward) [
                { c with
                    Position = Direction.next c.Direction c.Position
                    Traveled = c.Traveled + 1 }
            ]
            @ List.optionals (c.Traveled >= props.MinForward) [
                { Position = Direction.next (Direction.rotateLeft c.Direction) c.Position
                  Direction = Direction.rotateLeft c.Direction
                  Traveled = 1 }
                { Position = Direction.next (Direction.rotateRight c.Direction) c.Position
                  Direction = Direction.rotateRight c.Direction
                  Traveled = 1 }
            ]

        let isInBounds pt =
            pt.X >= 0 && pt.X < width cm && pt.Y >= 0 && pt.Y < height cm

        let goal = { X = width cm - 1; Y = height cm - 1 }

        let rec leastHeatLoss' () =
            state {
                let! state = State.getState
                let distances, _, visiting : _ * _ * PriorityQueue<_, _> = state

                if visiting.Count = 0 then
                    return
                        distances
                        |> Map.filter (fun key _ ->
                            key.Position = goal && key.Traveled >= props.StoppingDistance)
                        |> Seq.map _.Value
                        |> Seq.min

                else
                    let current = visiting.Dequeue ()
                    let currentDist = distances |> distanceTo current

                    let neighbors = neighbors current |> List.filter (_.Position >> isInBounds)

                    for neighbor in neighbors do
                        let! distances, previous, visiting = State.getState
                        let neighborDist = distances |> distanceTo neighbor
                        let maybeShorterDist = currentDist + heatLoss cm neighbor.Position

                        if maybeShorterDist < neighborDist then
                            let distances = Map.add neighbor maybeShorterDist distances
                            let previous = Map.add neighbor current previous
                            visiting.Enqueue (neighbor, maybeShorterDist)
                            do! State.putState (distances, previous, visiting)

                    return! leastHeatLoss' ()
            }

        let start =
            { Position = { X = 0; Y = 0 }
              Direction = None
              Traveled = 0 }

        let firstRight =
            { Position = { X = 1; Y = 0 }
              Direction = Right
              Traveled = 1 }

        let firstDown =
            { Position = { X = 0; Y = 1 }
              Direction = Down
              Traveled = 1 }

        let distances =
            Map.empty
            |> Map.add start 0L
            |> Map.add firstRight (heatLoss cm firstRight.Position)
            |> Map.add firstDown (heatLoss cm firstDown.Position)

        let previous = Map.empty |> Map.add firstRight start |> Map.add firstDown start

        let visiting =
            let queue = PriorityQueue ()
            queue.Enqueue (firstRight, heatLoss cm firstRight.Position)
            queue.Enqueue (firstDown, heatLoss cm firstDown.Position)
            queue

        (distances, previous, visiting) |> State.eval (leastHeatLoss' ())


module Parsers =
    open FParsec

    let cityMap<'a> : Parser<CityMap, 'a> =
        let line = many1 (digit |>> (fun ch -> int64 (ch - '0')))
        sepEndBy line newline |>> CityMap.init


let printCrucibleStats (console: IConsole) crucibleProps cityMap =
    let lowestHeatLoss = CityMap.leastHeatLoss crucibleProps cityMap
    console.WriteLine $"Least heat loss from moving the crucible: {lowestHeatLoss}"


type Options =
    { Input: FileInfo
      MinForward: int
      MaxForward: int
      StoppingDistance: int }


let run (options: Options) (console: IConsole) =
    task {
        return
            runParserOnStream Parsers.cityMap () options.Input
            |> Result.map (
                printCrucibleStats
                    console
                    { MinForward = options.MinForward
                      MaxForward = options.MaxForward
                      StoppingDistance = options.StoppingDistance }
            )
    }

let command =
    let cmd = Command.create "day17" "Clumsy Crucible" run

    cmd.AddOption
    <| Option<int> (
        aliases = [| "-m"; "--min-forward" |],
        description = "minimum number of blocks before the crucible can turn",
        getDefaultValue = fun () -> 0
    )

    cmd.AddOption
    <| Option<int> (
        aliases = [| "-x"; "--max-forward" |],
        description = "maximum number of blocks the crucible can go straight",
        getDefaultValue = fun () -> 3
    )

    cmd.AddOption
    <| Option<int> (
        aliases = [| "-s"; "--stopping-distance" |],
        description = "how far the crucible must move before it can stop",
        getDefaultValue = fun () -> 0
    )

    cmd
