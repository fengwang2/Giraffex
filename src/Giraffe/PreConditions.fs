[<AutoOpen>]
module Giraffe.PreConditions

open System
open System.Linq
open Microsoft.AspNetCore.Http
open Microsoft.AspNetCore.Http.Headers
open Microsoft.Extensions.Primitives
open Microsoft.Net.Http.Headers
open Giraffe.Common

type PreCondition =
    | NotSpecified
    | NotModified
    | ConditionFailed
    | IsMatch

type EntityTagHeaderValue with
    member __.FromString (isWeak : bool) (eTag : string) =
        EntityTagHeaderValue(StringSegment(eTag), isWeak)

type HttpContext with

    member private this.IsHeadOrGetRequest() =
        HttpMethods.IsHead this.Request.Method || HttpMethods.IsGet this.Request.Method

    member private __.ValidateIfMatch (eTag : EntityTagHeaderValue option) (requestHeaders : RequestHeaders) =
        match  isNotNull requestHeaders.IfMatch
            && requestHeaders.IfMatch.Any() with
        | false -> NotSpecified
        | true  ->
            match eTag with
            | None      -> ConditionFailed
            | Some eTag ->
                requestHeaders.IfMatch
                |> Seq.exists (fun t -> t.Compare(eTag, true))
                |> function
                    | true  -> IsMatch
                    | false -> ConditionFailed

    member private __.ValidateIfUnmodifiedSince (lastModified : DateTimeOffset option) (requestHeaders : RequestHeaders) =
        match requestHeaders.IfUnmodifiedSince.HasValue with
        | false -> NotSpecified
        | true  ->
            match lastModified with
            | None              -> IsMatch
            | Some lastModified ->
                match  requestHeaders.IfUnmodifiedSince.Value > DateTimeOffset.UtcNow
                    || requestHeaders.IfUnmodifiedSince.Value >= lastModified with
                | true  -> IsMatch
                | false -> ConditionFailed

    member private this.ValidateIfNoneMatch (eTag : EntityTagHeaderValue option) (requestHeaders : RequestHeaders) =
        match  isNotNull requestHeaders.IfNoneMatch
            && requestHeaders.IfNoneMatch.Any() with
        | false -> NotSpecified
        | true  ->
            match eTag with
            | None      -> IsMatch
            | Some eTag ->
                requestHeaders.IfNoneMatch
                |> Seq.exists (fun t -> t.Compare(eTag, false))
                |> function
                    | false -> IsMatch
                    | true  ->
                        match this.IsHeadOrGetRequest() with
                        | true  -> NotModified
                        | false -> ConditionFailed

    member private this.ValidateIfModifiedSince (lastModified : DateTimeOffset option) (requestHeaders : RequestHeaders) =
        match  requestHeaders.IfModifiedSince.HasValue
            && this.IsHeadOrGetRequest() with
        | false -> NotSpecified
        | true  ->
            match lastModified with
            | None              -> IsMatch
            | Some lastModified ->
                match  requestHeaders.IfModifiedSince.Value <= DateTimeOffset.UtcNow
                    && requestHeaders.IfModifiedSince.Value < lastModified with
                | true  -> IsMatch
                | false -> NotModified

    member this.ValidatePreConditions (eTag : EntityTagHeaderValue option) (lastModified : DateTimeOffset option) =
        // Parse headers
        let responseHeaders = this.Response.GetTypedHeaders()
        let requestHeaders  = this.Request.GetTypedHeaders()

        // Helper bind functions to chain validation functions
        let bind (result : RequestHeaders -> PreCondition) =
            function
            | NotSpecified    -> result requestHeaders
            | IsMatch         -> result requestHeaders
            | ConditionFailed -> ConditionFailed
            | NotModified     -> NotModified

        let ifNotSpecified (result : RequestHeaders -> PreCondition) =
            function
            | NotSpecified    -> result requestHeaders
            | IsMatch         -> IsMatch
            | ConditionFailed -> ConditionFailed
            | NotModified     -> NotModified

        // Set ETag and Last-Modified in the response
        if eTag.IsSome         then responseHeaders.ETag         <- eTag.Value
        if lastModified.IsSome then responseHeaders.LastModified <- Nullable(lastModified.Value)

        // Validate headers in correct precedence
        // RFC: https://tools.ietf.org/html/rfc7232#section-6
        this.ValidateIfMatch eTag requestHeaders
        |> ifNotSpecified (this.ValidateIfUnmodifiedSince lastModified)
        |> bind (this.ValidateIfNoneMatch eTag)
        |> ifNotSpecified (this.ValidateIfModifiedSince lastModified)

    member this.NotModifiedResponse() =
        this.SetStatusCode StatusCodes.Status304NotModified
        Some this

    member this.PreConditionFailedResponse() =
        this.SetStatusCode StatusCodes.Status412PreconditionFailed
        Some this