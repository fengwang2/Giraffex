module Giraffe.HttpContextExtensions

open System
open System.IO
open System.Reflection
open System.ComponentModel
open Microsoft.AspNetCore.Http
open Microsoft.Extensions.Primitives
open Microsoft.Extensions.Logging
open Microsoft.Net.Http.Headers
open Giraffe.Common

type HttpContext with

    /// ---------------------------
    /// Dependency management
    /// ---------------------------

    member this.GetService<'T>() =
        this.RequestServices.GetService(typeof<'T>) :?> 'T

    member this.GetLogger<'T>() =
        this.GetService<ILogger<'T>>()

    /// ---------------------------
    /// Model binding
    /// ---------------------------

    member this.ReadBodyFromRequest() =
        async {
            let body = this.Request.Body
            use reader = new StreamReader(body, true)
            return! reader.ReadToEndAsync() |> Async.AwaitTask
        }

    member this.BindJson<'T>() =
        async {
            let! body = this.ReadBodyFromRequest()
            return deserializeJson<'T> body
        }

    member this.BindXml<'T>() =
        async {
            let! body = this.ReadBodyFromRequest()
            return deserializeXml<'T> body
        }

    member this.BindForm<'T>() =
        async {
            let! form = this.Request.ReadFormAsync() |> Async.AwaitTask
            let obj   = Activator.CreateInstance<'T>()
            let props = obj.GetType().GetProperties(BindingFlags.Instance ||| BindingFlags.Public)
            props
            |> Seq.iter (fun p ->
                let strValue = ref (StringValues())
                if form.TryGetValue(p.Name, strValue)
                then
                    let converter = TypeDescriptor.GetConverter p.PropertyType
                    let value = converter.ConvertFromInvariantString(strValue.Value.ToString())
                    p.SetValue(obj, value, null))
            return obj
        }

    member this.BindQueryString<'T>() =
        async {
            let query = this.Request.Query
            let obj   = Activator.CreateInstance<'T>()
            let props = obj.GetType().GetProperties(BindingFlags.Instance ||| BindingFlags.Public)
            props
            |> Seq.iter (fun p ->
                let strValue = ref (StringValues())
                if query.TryGetValue(p.Name, strValue)
                then
                    let converter = TypeDescriptor.GetConverter p.PropertyType
                    let value = converter.ConvertFromInvariantString(strValue.Value.ToString())
                    p.SetValue(obj, value, null))
            return obj
        }

    member this.BindModel<'T>() =
        async {
            let method = this.Request.Method
            return!
                if method.Equals "POST" || method.Equals "PUT" then
                    let original = this.Request.ContentType
                    let parsed   = ref (MediaTypeHeaderValue("*/*"))
                    match MediaTypeHeaderValue.TryParse(original, parsed) with
                    | false -> failwithf "Could not parse Content-Type HTTP header value '%s'" original
                    | true  ->
                        match parsed.Value.MediaType with
                        | "application/json"                  -> this.BindJson<'T>()
                        | "application/xml"                   -> this.BindXml<'T>()
                        | "application/x-www-form-urlencoded" -> this.BindForm<'T>()
                        | _ -> failwithf "Cannot bind model from Content-Type '%s'" original
                else this.BindQueryString<'T>()
        }