// SPDX-License-Identifier: GPL-3.0-only

open Advent2023

[<EntryPoint>]
let main args =
    let awaiter = (CommandLine.run args).GetAwaiter ()
    awaiter.GetResult ()
