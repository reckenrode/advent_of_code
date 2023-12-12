// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day3

open System.CommandLine
open System.IO
open type System.Int32
open System.Text.RegularExpressions

open FSharp.Control

open Advent2023.CommandLine
open Advent2023.Support


type Part = { Name: string; Location: Point<int> }

module Part =
    let name (part: Part) = part.Name
    let location (part: Part) = part.Location


type Number =
    { Value: int
      Location: Point<int>
      Length: int }

module Number =
    let value (num: Number) = num.Value
    let location (num: Number) = num.Location
    let length (num: Number) = num.Length

    let intersects pt num =
        let left = location num |> Point.x
        let right = left + length num
        let row = location num |> Point.y
        Point.y pt = row && Point.x pt >= left && Point.x pt < right


type Gear =
    { Location: Point<int>
      PartNumbers: Number * Number }

module Gear =
    let location (g: Gear) = g.Location
    let partNumbers (g: Gear) = g.PartNumbers
    let firstNumber = partNumbers >> fst
    let secondNumber = partNumbers >> snd

    let ratio g =
        (firstNumber g |> Number.value) * (secondNumber g |> Number.value)


type Schematic =
    { Numbers: List<Number>
      Parts: List<Part> }

module Schematic =
    let numbers (sch: Schematic) = sch.Numbers
    let parts (sch: Schematic) = sch.Parts

    let gears schematic =
        parts schematic
        |> List.filter (fun part -> Part.name part = "*")
        |> List.choose (fun part ->
            let location = Part.location part
            let adjacentPoints = Point.adjacentPoints location

            let adjacentParts =
                numbers schematic
                |> List.filter (fun num ->
                    List.exists (fun pt -> Number.intersects pt num) adjacentPoints)

            match adjacentParts with
            | [ fst; snd ] ->
                Some
                    { Location = location
                      PartNumbers = (fst, snd) }
            | _ -> None)

    let partNumbers schematic =
        let adjacentPoints =
            parts schematic
            |> Seq.collect (Part.location >> Point.adjacentPoints)
            |> Set.ofSeq

        numbers schematic
        |> List.filter (fun num -> Set.exists (fun pt -> Number.intersects pt num) adjacentPoints)
        |> List.map Number.value

    let fromLines lines =
        let numRegex = Regex @"\d+"

        let numbers =
            [ for row, line in List.indexed lines do
                  for numMatch in numRegex.Matches line do
                      let didParse, value = TryParse numMatch.Value

                      if didParse then
                          yield
                              { Value = value
                                Location = { X = numMatch.Index; Y = row }
                                Length = numMatch.Length } ]

        let partRegex = Regex @"[^.\d]"

        let parts =
            [ for row, line in List.indexed lines do
                  for partMatch in partRegex.Matches line do
                      yield
                          { Name = partMatch.Value
                            Location = { X = partMatch.Index; Y = row } } ]

        { Numbers = numbers; Parts = parts }


type Options = { Input: FileInfo }

let run (options: Options) (console: IConsole) =
    task {
        use file = options.Input.OpenRead ()
        use reader = new StreamReader (file)
        let! lines = TaskSeq.toListAsync (lines reader)
        let schematic = Schematic.fromLines lines

        let partNumbers = Schematic.partNumbers schematic
        let partSum = List.sum partNumbers
        console.WriteLine $"Sum of all part numbers: {partSum}"

        let gears = Schematic.gears schematic
        let gearSum = gears |> List.map Gear.ratio |> List.sum
        console.WriteLine $"Sum of all gear ratios: {gearSum}"

        return Ok ()
    }

let command = Command.create "day3" "Gear Ratios" run
