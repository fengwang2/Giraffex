module AspNetCore.Lambda.FormatExpressions

open System
open System.Text.RegularExpressions
open Microsoft.FSharp.Reflection
open FSharp.Core
open FSharp.Core.Printf

let formatStringMap =
    dict [
    // Char    Regex                    Parser
    // ----------------------------------------------------------
        'b', ("(?i:(true|false)){1}",   bool.Parse   >> box)  // bool
        'c', ("(.{1})",                 Char.Parse   >> box)  // char
        's', ("(.+)",                                   box)  // string
        'i', ("(-?\d+)",                Int32.Parse  >> box)  // int
        'd', ("(-?\d+)",                Int64.Parse  >> box)  // int64
        'f', ("(-?\d+\.{1}\d+)",        Double.Parse >> box)  // float
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

let tryMatchInput (format : StringFormat<_, 'T>) (input : string) =    
    let pattern, formatChars = 
        format.Value
        |> convertToRegexPatternAndFormatChars
    
    let result = Regex.Match(input, pattern)

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