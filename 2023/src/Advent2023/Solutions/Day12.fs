// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Solutions.Day12

open System.CommandLine
open System.Text.RegularExpressions

open FSharpx

open Advent2023.CommandLine
open Advent2023.Support


type ConditionRecord = { Springs: string; Groups: list<int> }

module ConditionRecord =
    let private state = State.state

    [<Struct>]
    type private SpringType =
        | Operational
        | Damaged
        | Unknown

    [<Struct>]
    type private Run = Run of SpringType * int

    let private split springs =
        let classify (m: Match) =
            if m.Length = 0 then
                failwith "invalid empty spring condition"
            else
                match m.ValueSpan[0] with
                | '.' -> Run (Operational, m.Length)
                | '#' -> Run (Damaged, m.Length)
                | '?' -> Run (Unknown, m.Length)
                | _ -> failwith "invalid spring condition"

        let regex = Regex @"(.)\1*"
        regex.Matches springs |> Seq.map classify |> Seq.toList

    let private memoize f gs rs =
        state {
            let! memo = State.getState

            match Map.tryFind (gs, rs) memo with
            | Some value -> return value
            | None ->
                let! value = f gs rs
                do! updateState (Map.add (gs, rs) value)
                return value
        }

    let possibleArrangementCount cr =
        let rec loop gs rs =
            state {
                match rs, gs with
                // Base case. Everything matched.
                | [], [] -> return 1L
                // The run of damaged springs is longer than next group, so the sequence is invalid.
                | Run (Damaged, len) :: _, g :: _ when g < len -> return 0L
                // Remove matching runs and continue counting
                | Run (Damaged, len) :: Run (Operational, _) :: rs, g :: gs
                | Run (Damaged, len) :: Run (Unknown, 1) :: rs, g :: gs
                | Run (Damaged, len) :: ([] as rs), g :: gs when g = len ->
                    return! memoize loop gs rs
                | Run (Damaged, len1) :: Run (Unknown, len2) :: rs, g :: gs when g = len1 ->
                    let run = Run (Unknown, len2 - 1)
                    return! memoize loop gs (run :: rs)
                | Run (Operational, _) :: rs, gs -> return! memoize loop gs rs
                // Check whether an unknown is damaged or operational
                | Run (Unknown, len) :: rs, gs ->
                    let run = Run (Damaged, 1)
                    let rs = if len = 1 then rs else Run (Unknown, len - 1) :: rs
                    let! lhs = memoize loop gs (run :: rs)
                    let! rhs = memoize loop gs rs
                    return lhs + rhs
                // Coalesce runs of damaged springs
                | Run (Damaged, len1) :: Run (Damaged, len2) :: rs, gs ->
                    let run = Run (Damaged, len1 + len2)
                    return! memoize loop gs (run :: rs)
                // Coalesce a damaged springs with unknown springs one at a time
                | Run (Damaged, len1) :: Run (Unknown, len2) :: rs, gs ->
                    return!
                        memoize loop gs [
                            yield Run (Damaged, len1 + 1)
                            if len2 - 1 > 0 then
                                yield Run (Unknown, len2 - 1)
                            yield! rs
                        ]
                // The damage run can’t fit the requested group size, so don’t count it.
                | Run (Damaged, len) :: _, g :: _ when g > len -> return 0L
                | [], _
                | _, [] -> return 0L
                // Suppress exhaustiveness warning and log any cases that may have been missed.
                | _, _ ->
                    return
                        failwith
                            $"unhandled case: gs = %A{gs}, rs = %A{rs} for %A{cr.Springs} with groups = %A{cr.Groups}"
            }

        State.eval (loop cr.Groups (split cr.Springs)) Map.empty


    let unfold n cr =
        { Springs = String.concat "?" (List.replicate n cr.Springs)
          Groups = List.concat (List.replicate n cr.Groups) }

module Parsers =
    open FParsec

    let record<'a> : Parser<ConditionRecord, 'a> =
        let springs = manyChars (choice [ pchar '.'; pchar '#'; pchar '?' ])
        let groups = sepBy pint32 (pchar ',')

        pipe3 springs spaces1 groups (fun springs _ groups ->
            { Springs = springs; Groups = groups })

    let records<'a> : Parser<list<ConditionRecord>, 'a> =
        sepEndBy record newline .>> eof


let printRecordInfo (console: IConsole) records =
    let sum = records |> List.map ConditionRecord.possibleArrangementCount |> List.sum
    console.WriteLine $"Sum of counts (part 1): {sum}"

    let sum =
        records
        |> List.map (ConditionRecord.unfold 5 >> ConditionRecord.possibleArrangementCount)
        |> List.sum

    console.WriteLine $"Sum of counts (part 2): {sum}"


let command =
    Command.create "day12" "Hot Springs" (runSolution printRecordInfo Parsers.records)
