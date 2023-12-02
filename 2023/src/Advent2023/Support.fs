// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Support

open System
open System.CommandLine
open System.CommandLine.NamingConventionBinder
open System.IO
open System.Reflection
open System.Threading.Tasks

open FSharp.Control
open FSharpx
open FSharpx.Text


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
    | Ok code -> code
    | Error message ->
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
