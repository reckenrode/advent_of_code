// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Support

open System
open System.CommandLine
open System.CommandLine.NamingConventionBinder
open System.IO
open System.Numerics
open System.Reflection
open System.Text
open System.Threading.Tasks

open FParsec
open FSharp.Control
open FSharpx
open FSharpx.Text


let printErrorAndExit error exitCode (console: IConsole) =
    console.WriteLine error
    exitCode

let printErrorsAndExit errors exitCode (console: IConsole) =
    for error in errors do
        console.WriteLine error

    exitCode

let runParserOnStream parser state (file: FileInfo) =
    use stream = file.OpenRead ()
    runParserOnStream parser state file.Name stream Encoding.UTF8

let register (root: RootCommand) =
    let maybe = FSharpx.Option.maybe

    let getDayNumber s =
        maybe {
            let! matchResult = Regex.tryMatch @"[A-Za-z](\d+)" s
            let! day = List.tryHead matchResult.GroupValues
            return! Option.ofBoolAndValue (Int32.TryParse day)
        }
        |> Option.defaultValue -1

    let getCommand (t: Type) =
        maybe {
            let! props = t.GetProperties () |> Option.ofObj

            let! cmd =
                props
                |> Seq.filter (fun (p: PropertyInfo) ->
                    p.Name = "command" && p.PropertyType = typeof<Command>)
                |> Seq.tryExactlyOne

            return downcast cmd.GetValue null
        }

    let assembly = Assembly.GetExecutingAssembly ()

    let commands =
        assembly.GetTypes ()
        |> Array.choose getCommand
        |> Array.sortBy (fun (cmd: Command) -> getDayNumber cmd.Name)

    commands |> Array.iter root.AddCommand
    root

let handleFailure (console: IConsole) =
    function
    | Result.Ok code -> code
    | Result.Error message ->
        console.Error.Write $"Error parsing file: {message}"
        1

let rec lines (reader: TextReader) =
    taskSeq {
        match! reader.ReadLineAsync () with
        | null -> ()
        | line ->
            yield line
            yield! lines reader
    }

module Command =
    let create name description (handler: 'a -> IConsole -> Task<int>) =
        let cmd = Command (name, description, Handler = CommandHandler.Create handler)

        cmd.AddOption
        <| Option<FileInfo> (
            aliases = [| "-i"; "--input" |],
            description = "the day’s input file",
            IsRequired = true
        )

        cmd

module List =
    let liftResult parsed =
        parsed
        |> List.fold
            (fun result elem ->
                match (result, elem) with
                | Result.Ok xs, Success (result, _, _) -> Result.Ok (result :: xs)
                | Result.Ok _, Failure (message, _, _) -> Result.Error [ message ]
                | Result.Error errors, Success _ -> Result.Error errors
                | Result.Error errors, Failure (message, _, _) -> Result.Error (message :: errors))
            (Result.Ok [])
        |> Result.bimap List.rev List.rev

module ParserResult =
    let toResult =
        function
        | Success (result, _, _) -> Result.Ok result
        | Failure (message, _, _) -> Result.Error message

let inline gcd (lhs: 'a) (rhs: 'a) : 'a :> IBinaryInteger<'a> =
    let zero = 'a.Zero
    let one = 'a.One
    let two = 'a.One + 'a.One

    let rec loop lhs rhs counter =
        if lhs = one && rhs = one then
            one
        elif lhs = rhs then
            lhs * counter
        else
            let struct (lhsQuo, lhsRem) = 'a.DivRem (lhs, two)
            let struct (rhsQuo, rhsRem) = 'a.DivRem (rhs, two)

            match lhsRem = zero, rhsRem = zero with
            | true, true -> loop lhsQuo rhsQuo counter * two
            | true, false -> loop lhsQuo rhs counter
            | false, true -> loop lhs rhsQuo counter
            | false, false when lhs < rhs -> loop rhs lhs counter
            | false, false -> loop (lhs - rhs) rhs counter

    loop lhs rhs 'a.One

let inline lcm lhs rhs =
    let gcd = gcd lhs rhs

    if gcd = rhs || gcd = rhs then
        max lhs rhs
    else
        lhs * rhs / gcd
