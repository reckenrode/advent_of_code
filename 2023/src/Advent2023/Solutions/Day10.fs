// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day10

open System.CommandLine
open System.IO

open FSharpx

open Advent2023.CommandLine
open Advent2023.Support


[<Struct>]
type Maze = Maze of char[,]

module Maze =
    let init lst =
        let len1, len2 = String.length (List.head lst), List.length lst
        let grid = Array2D.zeroCreate len1 len2

        lst
        |> List.iteri (fun rowIndex row ->
            row |> String.iteri (fun colIndex cell -> grid[colIndex, rowIndex] <- cell))

        Maze grid

    let start (Maze m) =
        m
        |> Array2D.rows
        |> Seq.indexed
        |> Seq.tryPick (fun (rowIndex, row) ->
            row
            |> Seq.indexed
            |> Seq.tryPick (fun (columnIndex, cell) ->
                if cell = 'S' then
                    Some { X = columnIndex; Y = rowIndex }
                else
                    None))

    let rec neighbors (Maze m) pt =
        let isInBounds pt =
            pt.X >= 0 && pt.Y >= 0 && pt.X < Array2D.length1 m && pt.Y < Array2D.length2 m

        let isConnected pt p =
            isInBounds p && p |> neighbors (Maze m) |> List.exists ((=) pt)

        match m[pt.X, pt.Y] with
        | '|' -> [ { pt with Y = pt.Y - 1 }; { pt with Y = pt.Y + 1 } ]
        | '-' -> [ { pt with X = pt.X - 1 }; { pt with X = pt.X + 1 } ]
        | 'L' -> [ { pt with Y = pt.Y - 1 }; { pt with X = pt.X + 1 } ]
        | 'J' -> [ { pt with Y = pt.Y - 1 }; { pt with X = pt.X - 1 } ]
        | '7' -> [ { pt with Y = pt.Y + 1 }; { pt with X = pt.X - 1 } ]
        | 'F' -> [ { pt with Y = pt.Y + 1 }; { pt with X = pt.X + 1 } ]
        | 'S' ->
            List.filter (isConnected pt) [
                { pt with X = pt.X - 1 }
                { pt with X = pt.X + 1 }
                { pt with Y = pt.Y - 1 }
                { pt with Y = pt.Y + 1 }
            ]
        | _ -> []
        |> List.filter isInBounds

    let private walk m startPt nextPt =
        let rec walk' dist prev pt =
            seq {
                if pt <> startPt then
                    yield struct (dist, pt)
                    yield! walk' (dist + 1) pt (neighbors m pt |> List.find ((<>) prev))
            }

        seq {
            yield struct (0, startPt)
            yield! walk' 1 startPt nextPt
        }

    let simplify (Maze g as m) =
        let startPt = start m |> Option.getOrFail "maze did not contain a starting point"

        let path =
            walk m startPt (neighbors m startPt |> List.head)
            |> Seq.map (fun struct (_, pt) -> pt)
            |> List.ofSeq

        let width = (path |> List.map _.X |> List.max) + 1
        let height = (path |> List.map _.Y |> List.max) + 1

        let grid = Array2D.create width height '.'
        List.iter (fun pt -> grid[pt.X, pt.Y] <- g[pt.X, pt.Y]) path

        let startType =
            match neighbors m startPt |> List.sort with
            | [ lhs; rhs ] when startPt.X - 1 = lhs.X && startPt.X + 1 = rhs.X -> '-'
            | [ lhs; rhs ] when startPt.Y - 1 = lhs.Y && startPt.Y + 1 = rhs.Y -> '|'
            | [ lhs; rhs ] when startPt.Y + 1 = lhs.Y && startPt.X + 1 = rhs.X -> 'F'
            | [ lhs; rhs ] when startPt.X - 1 = lhs.X && startPt.Y + 1 = rhs.Y -> '7'
            | [ lhs; rhs ] when startPt.X - 1 = lhs.X && startPt.Y - 1 = rhs.Y -> 'J'
            | [ lhs; rhs ] when startPt.X - 1 = lhs.X && startPt.Y - 1 = rhs.Y -> 'L'
            | _ -> failwith "invalid neighbors"

        grid[startPt.X, startPt.Y] <- startType

        Maze grid

    type private FillState =
        | Inside
        | Outside
        | Vertical of FillState * char

    let countInside m =
        let (Maze grid) = simplify m

        let fillState p s =
            match s, grid[p.X, p.Y] with
            | Inside, '-' -> Outside
            | Outside, '-' -> Inside
            | s, ('7' as c)
            | s, ('F' as c) -> Vertical (s, c)
            | Vertical (Inside, 'F'), 'J'
            | Vertical (Inside, '7'), 'L' -> Outside
            | Vertical (Outside, 'F'), 'J'
            | Vertical (Outside, '7'), 'L' -> Inside
            | Vertical (s, '7'), 'J'
            | Vertical (s, 'F'), 'L'
            | s, '|'
            | s, '.' -> s
            | _ -> failwith $"invalid fill state"

        let mutable count = 0

        for x in 0 .. Array2D.length1 grid - 1 do
            let mutable state = fillState { X = x; Y = 0 } Outside

            for y in 1 .. Array2D.length2 grid - 1 do
                state <- fillState { X = x; Y = y } state

                if state = Inside && grid[x, y] = '.' then
                    count <- count + 1

        count

    let farthestPoint m =
        let startPt = start m |> Option.getOrFail "maze did not contain a starting point"

        neighbors m startPt
        |> List.map (walk m startPt >> set)
        |> Set.intersectMany
        |> Set.maxElement


module Parsers =
    open FParsec

    let maze<'a> : Parser<Maze, 'a> =
        let line = manySatisfy ((<>) '\n')
        let maze = sepEndBy line newline |>> Maze.init
        maze .>> eof


let printMazeInfo (console: IConsole) maze =
    let struct (dist, _) = Maze.farthestPoint maze
    console.WriteLine $"Distance to farthest point: {dist}"

    let numInside = Maze.countInside maze
    console.WriteLine $"Cells inside pipeline walls: {numInside}"


let command =
    Command.create "day10" "Pipe Maze" (runSolution printMazeInfo Parsers.maze)
