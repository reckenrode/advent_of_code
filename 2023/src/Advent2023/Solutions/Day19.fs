// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day19

open System
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
type RegisterRange = { Lower: int64; Upper: int64 }

module RegisterRange =
    let isValid r = r.Lower <= r.Upper
    let count r = r.Upper - r.Lower + 1L

[<Struct>]
type RegisterFile =
    private
        { PC: int
          Status: voption<bool>
          X: RegisterRange
          M: RegisterRange
          A: RegisterRange
          S: RegisterRange }

module RegisterFile =
    let isValid rf =
        RegisterRange.isValid rf.X
        && RegisterRange.isValid rf.M
        && RegisterRange.isValid rf.A
        && RegisterRange.isValid rf.S

    let combinations rf =
        RegisterRange.count rf.X
        * RegisterRange.count rf.M
        * RegisterRange.count rf.A
        * RegisterRange.count rf.S

type Operation = RegisterFile -> list<RegisterFile>

[<Struct>]
type Workflow =
    private
        { EntryPoint: int
          MainMemory: array<Operation> }

module Workflow =
    module Parsers =
        open FParsec

        let private lessThan lhs rhs =
            ({ lhs with
                Upper = min lhs.Upper (rhs - 1L) },
             { lhs with Lower = max lhs.Lower rhs })

        let private greaterThan lhs rhs =
            let failed, passed = lessThan lhs (rhs + 1L)
            passed, failed

        let identifier<'a> : Parser<string, 'a> = many1Chars asciiLetter

        let register<'a>
            : Parser<(RegisterFile -> RegisterRange) *
              (RegisterFile -> RegisterRange -> RegisterFile), 'a> =
            choice [
                pchar 'x' >>. preturn (_.X, (fun r x -> { r with X = x }))
                pchar 'm' >>. preturn (_.M, (fun r m -> { r with M = m }))
                pchar 'a' >>. preturn (_.A, (fun r a -> { r with A = a }))
                pchar 's' >>. preturn (_.S, (fun r s -> { r with S = s }))
            ]

        let operator<'a> : Parser<_, 'a> =
            choice [ pchar '<' >>. preturn lessThan; pchar '>' >>. preturn greaterThan ]

        let number<'a> : Parser<_, 'a> = pint64

        let cmp<'a> : Parser<_, 'a> =
            let comparison =
                pipe3 register operator number (fun lens op rhs ->
                    let get, set = lens

                    fun registers ->
                        let lhs = get registers
                        let passed, failed = op lhs rhs
                        set registers passed, set registers failed)

            pipe2 (comparison .>> (pchar ':')) identifier (fun cmp target symbols registers ->
                let passed, failed = cmp registers

                [ if RegisterFile.isValid passed then
                      { passed with
                          PC = symbols |> Map.find target }
                  if RegisterFile.isValid failed then
                      { failed with PC = failed.PC + 1 } ])

        let jmp<'a> : Parser<_, 'a> =
            identifier
            |>> (fun target symbols registers ->
                [ { registers with
                      PC = Map.find target symbols } ])

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
                    [ { registers with
                          Status = ValueSome true } ]

            memory[1] <-
                fun registers ->
                    [ { registers with
                          Status = ValueSome false } ]

            rawMemory |> List.iteri (fun idx op -> memory[idx + 2] <- op symbols)

            return
                { EntryPoint = symbols |> Map.find "in"
                  MainMemory = memory }
        }

    let init workflow rating =
        { PC = workflow.EntryPoint
          Status = ValueNone
          A = { Lower = rating.a; Upper = rating.a }
          M = { Lower = rating.m; Upper = rating.m }
          S = { Lower = rating.s; Upper = rating.s }
          X = { Lower = rating.x; Upper = rating.x } }

    let rec private runWorkflow workflow registers =
        let rec loop accepted computations =
            let finished, pending =
                computations
                |> List.collect (fun r -> Array.item r.PC workflow.MainMemory r)
                |> List.partition (_.Status >> ValueOption.isSome)

            let newlyAccepted = List.filter (_.Status >> ((=) (ValueSome true))) finished

            if not (List.isEmpty pending) then
                loop (newlyAccepted :: accepted) pending
            else
                newlyAccepted :: accepted

        loop [] registers |> List.sumBy (List.map RegisterFile.combinations >> List.sum)

    let run workflow rating =
        runWorkflow workflow [ init workflow rating ] = 1L

    let countCombinations workflow =
        let registers =
            { PC = workflow.EntryPoint
              Status = ValueNone
              X = { Lower = 1L; Upper = 4000L }
              M = { Lower = 1L; Upper = 4000L }
              A = { Lower = 1L; Upper = 4000L }
              S = { Lower = 1L; Upper = 4000L } }

        runWorkflow workflow [ registers ]


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
    let accept rating =
        if Workflow.run workflow rating then Some rating else None

    let acceptedSums = ratings |> List.choose accept |> List.sumBy Rating.sum
    console.WriteLine $"Sum of part ratings that are accepted: {acceptedSums}"

    let combinations = Workflow.countCombinations workflow
    console.WriteLine $"Distinct combinations of ratings accepted: {combinations}"


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
