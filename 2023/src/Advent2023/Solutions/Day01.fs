// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day1

open System.CommandLine
open System.IO

open FSharp.Control
open FSharpx.Text

open Advent2023.Support


type Options = { Input: FileInfo }

let private revString (s: string) = s |> Seq.rev |> System.String.Concat

let private digits = "one|two|three|four|five|six|seven|eight|nine"
let private reverseDigits = revString digits

let private remap s =
    match s with
    | "one"
    | "eno" -> "1"
    | "two"
    | "owt" -> "2"
    | "three"
    | "eerht" -> "3"
    | "four"
    | "ruof" -> "4"
    | "five"
    | "evif" -> "5"
    | "six"
    | "xis" -> "6"
    | "seven"
    | "neves" -> "7"
    | "eight"
    | "thgie" -> "8"
    | "nine"
    | "enin" -> "9"
    | s -> s

let calibrate lines =
    [ for line in lines do
          let first = Regex.tryMatch $"({digits}|\d)" line |> Option.map _.GroupValues

          let second =
              Regex.tryMatch $"({reverseDigits}|\d)" (revString line)
              |> Option.map _.GroupValues

          let digits =
              match first, second with
              | Some [ fst ], Some [ snd ] -> $"{remap fst}{remap snd}"
              | Some [ fst ], None -> $"{remap fst}{remap fst}"
              | x -> failwith $"line did not contain enough digits %A{x}{line}"

          let value =
              let didParse, value = System.Int32.TryParse digits

              if not didParse then
                  failwith $"{digits} is not an integer"
              else
                  value

          yield value ]

let run (options: Options) (console: IConsole) =
    task {
        use file = options.Input.OpenRead ()
        use reader = new StreamReader (file)
        let lines = TaskSeq.toList (lines reader)

        let calibrationValues = calibrate lines
        let calibrationSum = calibrationValues |> List.sum

        printfn $"the sum of all of the calibration values: {calibrationSum}"

        return 0
    }

let command = Command.create "day1" "Trebuchet?!" run
