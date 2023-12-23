// SPDX-License-Identifier: GPL-3.0-only

module Advent2023.Tests.Solutions.Day19

open Expecto

open FSharpx

open Advent2023.Solutions.Day19


[<Tests>]
let tests =
    testList "Day 19" [
        testList "Examples" [
            let workflow =
                Workflow.compile
                    "example"
                    "px{a<2006:qkq,m>2090:A,rfg}\n\
                    pv{a>1716:R,A}\n\
                    lnx{m>1548:A,A}\n\
                    rfg{s<537:gd,x>2440:R,A}\n\
                    qs{s>3448:A,lnx}\n\
                    qkq{x<1416:A,crn}\n\
                    crn{x>2662:A,R}\n\
                    in{s<1351:px,qqz}\n\
                    qqz{s>2770:qs,m<1801:hdj,R}\n\
                    gd{a>3333:R,R}\n\
                    hdj{m>838:A,pv}"

            let ratings =
                [ { x = 787
                    m = 2655
                    a = 1222
                    s = 2876 }
                  { x = 1679; m = 44; a = 2067; s = 496 }
                  { x = 2036; m = 264; a = 79; s = 2244 }
                  { x = 2461; m = 1339; a = 466; s = 291 }
                  { x = 2127
                    m = 1623
                    a = 2188
                    s = 1013 } ]

            test "Part 1" {
                let expectedAcceptedParts = [ 0; 2; 4 ]

                let acceptedParts =
                    match workflow with
                    | Ok workflow ->
                        ratings
                        |> List.indexed
                        |> List.choose (fun (idx, part) ->
                            if Workflow.run workflow part then Some idx else None)
                    | Error message -> failwith message

                Expect.equal acceptedParts expectedAcceptedParts "the expected parts were accepted"
            }

            let examples =
                [ workflow
                  Workflow.compile "example2" "in{a<2000:R,A}"
                  Workflow.compile
                      "example3"
                      "r{x>1000:A,foo}\n\
                      foo{m>5:R,A}\n\
                      in{a<2000:q,A}\n\
                      q{s<3000:R,r}" ]

            test "Part 2" {
                let expectedCombinations = [ 167409079868000L; 128064000000000L; 152085992995000L ]

                let combinations =
                    match Result.sequence examples with
                    | Ok workflows -> List.map Workflow.countCombinations workflows
                    | Error message -> failwith message

                Expect.equal combinations expectedCombinations "the expected parts were accepted"
            }
        ]
    ]
