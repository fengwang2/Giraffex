module Giraffe.FormatExpressions

open System.Text.RegularExpressions
open System.Net
open Microsoft.FSharp.Reflection
open FSharp.Core

let formatStringMap =
    dict [
    // Char    Regex                    Parser
    // ----------------------------------------------------------
        'b', ("(?i:(true|false)){1}",   bool.Parse           >> box)  // bool
        'c', ("(.{1})",                 char                 >> box)  // char
        's', ("(.+)",                   WebUtility.UrlDecode >> box)  // string
        'i', ("(-?\d+)",                int32                >> box)  // int
        'd', ("(-?\d+)",                int64                >> box)  // int64
        'f', ("(-?\d+\.{1}\d+)",        float                >> box)  // float
    ]

let convertToRegexPatternAndFormatChars (formatString : string) =
    let rec convert (chars : char list) =
        match chars with
        | '%' :: '%' :: tail ->
            let pattern, formatChars = convert tail
            "%" + pattern, formatChars
        | '%' :: c :: tail ->
            let pattern, formatChars = convert tail
            let regex, _ = formatStringMap.[c]
            regex + pattern, c :: formatChars
        | c :: tail ->
            let pattern, formatChars = convert tail
            c.ToString() + pattern, formatChars
        | [] -> "", []

    formatString.ToCharArray()
    |> Array.toList
    |> convert
    |> (fun (pattern, formatChars) -> sprintf "^%s$" pattern, formatChars)

let tryMatchInput (format : PrintfFormat<_,_,_,_, 'T>) (input : string) (ignoreCase : bool) =
    try
        let pattern, formatChars =
            format.Value
            |> Regex.Escape
            |> convertToRegexPatternAndFormatChars

        let options =
            match ignoreCase with
            | true  -> RegexOptions.IgnoreCase
            | false -> RegexOptions.None

        let result = Regex.Match(input, pattern, options)

        if result.Groups.Count <= 1
        then None
        else
            let groups =
                result.Groups
                |> Seq.cast<Group>
                |> Seq.skip 1

            let values =
                (groups, formatChars)
                ||> Seq.map2 (fun g c ->
                    let _, parser   = formatStringMap.[c]
                    let value       = parser g.Value
                    value)
                |> Seq.toArray

            let result =
                match values.Length with
                | 1 -> values.[0]
                | _ ->
                    let types =
                        values
                        |> Array.map (fun v -> v.GetType())
                    let tupleType = FSharpType.MakeTupleType types
                    FSharpValue.MakeTuple(values, tupleType)
            result
            :?> 'T
            |> Some
    with
    | _ -> None