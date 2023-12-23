// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day19

open System.CommandLine

open FSharpx

open Advent2023.CommandLine
open Advent2023.Support


[<Struct>]
type Rating =
    { x: int64
      m: int64
      a: int64
      s: int64 }

module Rating =
    let sum rating =
        rating.x + rating.m + rating.a + rating.s

    let zero = { x = 0L; m = 0L; a = 0L; s = 0L }


[<Struct>]
type RegisterFile =
    private
        { PC: int
          Status: ValueOption<bool>
          X: int64
          M: int64
          A: int64
          S: int64 }

type Operation = RegisterFile -> RegisterFile

[<Struct>]
type Workflow =
    private
        { EntryPoint: int
          MainMemory: array<Operation> }

module Workflow =
    module Parsers =
        open FParsec

        let identifier<'a> : Parser<string, 'a> = many1Chars asciiLetter

        let register<'a> : Parser<_, 'a> =
            choice [
                pchar 'x' >>. preturn _.X
                pchar 'm' >>. preturn _.M
                pchar 'a' >>. preturn _.A
                pchar 's' >>. preturn _.S
            ]

        let operator<'a> : Parser<_, 'a> =
            choice [ pchar '>' >>. preturn (>); pchar '<' >>. preturn (<) ]

        let number<'a> : Parser<_, 'a> = pint64

        let cmp<'a> : Parser<_, 'a> =
            let comparison =
                pipe3 register operator number (fun reg op rhs -> reg >> (fun lhs -> op lhs rhs))

            pipe2 (comparison .>> (pchar ':')) identifier (fun cmp target symbols registers ->
                if cmp registers then
                    { registers with
                        PC = Map.find target symbols }
                else
                    { registers with PC = registers.PC + 1 })

        let jmp<'a> : Parser<_, 'a> =
            identifier
            |>> (fun target symbols registers ->
                { registers with
                    PC = Map.find target symbols })

        let operation<'a> : Parser<_, 'a> = choice [ attempt cmp; jmp ]

        let funcDefinition<'a> : Parser<string * _, 'a> =
            let ops = sepBy operation (pchar ',')
            identifier .>>. (between (pchar '{') (pchar '}') ops)

        let workflow<'a> : Parser<list<_>, 'a> = sepEndBy1 funcDefinition newline

        let parseWorkflow filename =
            runParserOnString workflow () filename
            >> (function
            | Success (func, _, _) -> Result.Ok func
            | Failure (message, _, _) -> Result.Error message)

    let private result = Result.result

    let compile name ops =
        let defaultSymbols = Map [ "A", 0; "R", 1 ]

        result {
            let! workflow = Parsers.parseWorkflow name ops

            let symbols, rawMemory, memorySize =
                workflow
                |> List.fold
                    (fun (symbols, memory, location) (funcName, funcBody) ->
                        let updatedSymbols = symbols |> Map.add funcName location
                        let updatedMemory = memory @ funcBody
                        let nextLocation = location + List.length funcBody
                        updatedSymbols, updatedMemory, nextLocation)
                    (defaultSymbols, [], 2)

            let memory = Array.zeroCreate memorySize

            memory[0] <-
                fun registers ->
                    { registers with
                        Status = ValueSome true }

            memory[1] <-
                fun registers ->
                    { registers with
                        Status = ValueSome false }

            rawMemory |> List.iteri (fun idx op -> memory[idx + 2] <- op symbols)

            return
                { EntryPoint = symbols |> Map.find "in"
                  MainMemory = memory }
        }

    let init workflow rating =
        { PC = workflow.EntryPoint
          Status = ValueNone
          A = rating.a
          M = rating.m
          S = rating.s
          X = rating.x }

    let run workflow rating =
        let rec loop registers =
            match workflow.MainMemory[registers.PC]registers with
            | { Status = ValueSome acceptance } -> acceptance
            | registers -> loop registers

        init workflow rating |> loop


module Parsers =
    open FParsec

    let rating<'a> : Parser<_, 'a> =
        let category =
            choice [
                pchar 'x' >>. preturn (fun value r -> { r with x = value })
                pchar 'm' >>. preturn (fun value r -> { r with m = value })
                pchar 'a' >>. preturn (fun value r -> { r with a = value })
                pchar 's' >>. preturn (fun value r -> { r with s = value })
            ]

        let assignment = pipe2 (category .>> pchar '=') pint64 id

        between (pchar '{') (pchar '}') (sepBy assignment (pchar ','))
        |>> List.fold (fun r f -> f r) Rating.zero

    let input<'a> : Parser<_, 'a> =
        let workflowLine = many1Chars (noneOf [ '\n' ])

        sepEndBy workflowLine newline |>> String.concat "\n" .>> newline
        .>>. sepEndBy1 rating newline
        .>> eof


let printWorkflowResults (console: IConsole) workflow ratings =
    let acceptedSums =
        ratings
        |> List.choose (fun rating ->
            if Workflow.run workflow rating then Some rating else None)
        |> List.sumBy Rating.sum

    console.WriteLine $"Sum of part ratings that are accepted: {acceptedSums}"


let run (options: BasicOptions) (console: IConsole) =
    let result = Result.result

    task {
        return
            result {
                let! workflowText, ratings = runParserOnStream Parsers.input () options.Input
                let! workflow = Workflow.compile options.Input.Name workflowText
                return printWorkflowResults console workflow ratings
            }
    }


let command = Command.create "day19" "Aplenty" run
