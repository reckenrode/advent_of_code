// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.CommandLine

open System
open System.CommandLine
open System.CommandLine.Builder
open System.CommandLine.Parsing
open System.CommandLine.NamingConventionBinder
open System.IO
open System.Reflection
open System.Threading.Tasks

open FSharp.Control
open FSharpx
open FSharpx.Text


module Command =
    let create name description (f: 'a -> IConsole -> Task<Result<unit, string>>) =
        let handler a console =
            task {
                let! result = f a console

                return
                    match result with
                    | Ok () -> 0
                    | Error message ->
                        console.Error.Write $"{message}\n"
                        1
            }

        let cmd = Command (name, description, Handler = CommandHandler.Create handler)

        cmd.AddOption
        <| Option<FileInfo> (
            aliases = [| "-i"; "--input" |],
            description = "the day’s input file",
            IsRequired = true
        )

        cmd


let private register (root: RootCommand) =
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

let private builder =
    let assembly = Assembly.GetEntryAssembly ()
    let attribute = assembly.GetCustomAttribute typeof<AssemblyDescriptionAttribute>
    let description = (attribute :?> AssemblyDescriptionAttribute).Description
    let root = RootCommand (description = description, Name = "Advent2023")
    register root


let run (args: array<string>) =
    task {
        let builder = (CommandLineBuilder builder).UseDefaults ()
        let parser = builder.Build ()
        return! parser.InvokeAsync args
    }
