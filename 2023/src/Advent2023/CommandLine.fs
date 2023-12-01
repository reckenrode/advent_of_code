module Advent2023.CommandLine

open System.CommandLine
open System.CommandLine.Builder
open System.CommandLine.Parsing
open System.Reflection

open Advent2023.Solutions.Support

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
