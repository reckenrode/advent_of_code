// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day14

open System.CommandLine
open System.IO

open FSharpx

open Advent2023.CommandLine
open Advent2023.Support


[<Struct>]
type Direction =
    | North
    | South
    | East
    | West

module Direction =
    let move direction pt =
        match direction with
        | North -> { pt with Y = pt.Y - 1 }
        | South -> { pt with Y = pt.Y + 1 }
        | East -> { pt with X = pt.X + 1 }
        | West -> { pt with X = pt.X - 1 }


[<Struct>]
type Field = private Field of char[,]

module Field =
    let init xs =
        let firstLen = xs |> List.head |> String.length
        assert (List.forall (String.length >> ((=) firstLen)) xs)

        let storage = Array2D.create firstLen (List.length xs) '.'

        xs
        |> List.iteri (fun y ->
            String.iteri (fun x ->
                function
                | '#'
                | 'O' as c -> Array2D.set storage x y c
                | '.' -> ()
                | _ -> failwith "invalid character on field"))

        Field storage

    let height (Field field) = Array2D.length1 field

    let width (Field field) = Array2D.length2 field

    let private startValue field =
        function
        | North -> { X = 0; Y = height field - 1 }
        | South -> { X = 0; Y = 0 }
        | East -> { X = 0; Y = 0 }
        | West -> { X = width field - 1; Y = 0 }

    let private step =
        function
        | North -> { X = 1; Y = -1 }
        | South -> { X = 1; Y = 1 }
        | East -> { X = 1; Y = 1 }
        | West -> { X = -1; Y = 1 }

    let private endValue field =
        function
        | North -> { X = width field - 1; Y = 0 }
        | South ->
            { X = width field - 1
              Y = height field - 1 }
        | East ->
            { X = width field - 1
              Y = height field - 1 }
        | West -> { X = 0; Y = height field - 1 }

    let tilt direction (Field field) =
        let field = Array2D.copy field

        let move = Direction.move direction

        let tryRockAt pt =
            let x = Point.x pt
            let y = Point.y pt

            if x < 0 || y < 0 || x >= Array2D.length1 field || y >= Array2D.length2 field then
                None
            else
                Some (Array2D.get field x y)

        let roll pt =
            let newPt = move pt

            match tryRockAt newPt with
            | Some '.' ->
                Array2D.set field (Point.x pt) (Point.y pt) '.'
                Array2D.set field (Point.x newPt) (Point.y newPt) 'O'
                true
            | _ -> false

        let pts =
            [ let startPt = startValue (Field field) direction
              let step = step direction
              let endPt = endValue (Field field) direction

              for x in startPt.X .. step.X .. endPt.X do
                  for y in startPt.Y .. step.Y .. endPt.Y do
                      yield { X = x; Y = y } ]

        let rec loop didRoll =
            function
            | [] when didRoll -> loop false pts
            | [] -> ()
            | pt :: pts ->
                match tryRockAt pt with
                | Some 'O' ->
                    let didRoll = roll pt || didRoll
                    loop didRoll pts
                | _ -> loop didRoll pts

        loop false pts

        Field field

    let totalLoad direction (Field field) =
        let fieldSeq =
            function
            | North -> Array2D.rows >> Seq.rev
            | South -> Array2D.rows
            | East -> Array2D.columns
            | West -> Array2D.columns >> Seq.rev

        fieldSeq direction field
        |> Seq.indexed
        |> Seq.fold
            (fun total (idx, seq) ->
                total + (idx + 1) * (seq |> Seq.filter ((=) 'O') |> Seq.length))
            0


module Parsers =
    open FParsec

    let space<'a> : Parser<char, 'a> = choice [ pchar '.'; pchar '#'; pchar 'O' ]

    let field<'a> : Parser<Field, 'a> =
        let line = many1Chars space .>> newline
        many line .>> eof |>> Field.init


let runSpinCycle cycleCount field =
    let rec runSpinCycle' currentCycle (field: Field) =
        State.state {
            if currentCycle < cycleCount then
                let! memo = State.getState

                match Map.tryFind field memo with
                | Some (_, cycleSeen) ->
                    let cycleLength = currentCycle - cycleSeen
                    let finalCycle = cycleSeen + (cycleCount - cycleSeen) % cycleLength - 1

                    return
                        memo
                        |> Map.pick (fun _ (newField, cycle) ->
                            if cycle = finalCycle then Some newField else None)
                | None ->
                    let spinCycle = [ North; West; South; East ]
                    let newField = List.fold (flip Field.tilt) field spinCycle
                    do! updateState (Map.add field (newField, currentCycle))
                    return! runSpinCycle' (currentCycle + 1) newField
            else
                return field
        }

    State.eval (runSpinCycle' 0 field) Map.empty

let printSolution (console: IConsole) cycles field =
    let totalLoad = Field.tilt North field |> Field.totalLoad North
    console.WriteLine $"Total load (north beams): {totalLoad}"

    let tiltedField = runSpinCycle cycles field
    let finalLoad = Field.totalLoad North tiltedField

    console.WriteLine $"Total load (north beam, tilted heavily): {finalLoad}"


type Options = { Input: FileInfo; Cycles: int }


let run (options: Options) (console: IConsole) =
    task {
        return
            runParserOnStream Parsers.field () options.Input
            |> Result.map (printSolution console options.Cycles)
    }


let command =
    let cmd = Command.create "day14" "Parabolic Reflector Dish" run

    cmd.AddOption
    <| Option<int> (
        aliases = [| "-c"; "--cycles" |],
        description = "number of cycles (north, west, south, east) to run",
        getDefaultValue = fun () -> 1_000_000_000
    )

    cmd
