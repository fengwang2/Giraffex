# Giraffe

![Giraffe](https://raw.githubusercontent.com/giraffe-fsharp/Giraffe/develop/giraffe.png)

A functional ASP.NET Core micro web framework for building rich web applications.

Read [this blog post on functional ASP.NET Core](https://dusted.codes/functional-aspnet-core) for more information.

[![NuGet Info](https://buildstats.info/nuget/Giraffe?includePreReleases=true)](https://www.nuget.org/packages/Giraffe/)

| Windows | Linux |
| :------ | :---- |
| [![Windows Build status](https://ci.appveyor.com/api/projects/status/0ft2427dflip7wti/branch/develop?svg=true)](https://ci.appveyor.com/project/dustinmoris/giraffe/branch/develop) | [![Linux Build status](https://travis-ci.org/giraffe-fsharp/Giraffe.svg?branch=develop)](https://travis-ci.org/giraffe-fsharp/Giraffe/builds?branch=develop) |
| [![Windows Build history](https://buildstats.info/appveyor/chart/dustinmoris/giraffe?branch=develop&includeBuildsFromPullRequest=false)](https://ci.appveyor.com/project/dustinmoris/giraffe/history?branch=develop) | [![Linux Build history](https://buildstats.info/travisci/chart/giraffe-fsharp/Giraffe?branch=develop&includeBuildsFromPullRequest=false)](https://travis-ci.org/giraffe-fsharp/Giraffe/builds?branch=develop) |

#### ATTENTION:

Giraffe was formerly known as [ASP.NET Core Lambda](https://www.nuget.org/packages/AspNetCore.Lambda) and has been later [renamed to Giraffe](https://github.com/giraffe-fsharp/Giraffe/issues/15) to better distinguish from AWS Lambda and to establish its own unique brand.

The old NuGet package has been unlisted and will no longer receive any updates. Please use the [Giraffe NuGet package](https://www.nuget.org/packages/Giraffe) going forward.

## Table of contents

- [About](#about)
- [Installation](#installation)
- [Basics](#basics)
    - [HttpHandler](#httphandler)
    - [Combinators](#combinators)
        - [compose (>=>)](#compose-)
        - [choose](#choose)
    - [Tasks](#tasks)
- [Default HttpHandlers](#default-httphandlers)
    - [GET, POST, PUT, PATCH, DELETE](#get-post-put-patch-delete)
    - [mustAccept](#mustaccept)
    - [challenge](#challenge)
    - [signOff](#signoff)
    - [requiresAuthPolicy](#requiresauthpolicy)
    - [requiresAuthentication](#requiresauthentication)
    - [requiresRole](#requiresrole)
    - [requiresRoleOf](#requiresroleof)
    - [clearResponse](#clearResponse)
    - [route](#route)
    - [routef](#routef)
    - [routeCi](#routeci)
    - [routeCif](#routecif)
    - [routeBind](#routebind)
    - [routeStartsWith](#routestartswith)
    - [routeStartsWithCi](#routestartswithci)
    - [subRoute](#subroute)
    - [subRouteCi](#subrouteci)
    - [setStatusCode](#setstatuscode)
    - [setHttpHeader](#sethttpheader)
    - [setBody](#setbody)
    - [setBodyAsString](#setbodyasstring)
    - [text](#text)
    - [customJson](#customjson)
    - [json](#json)
    - [xml](#xml)
    - [negotiate](#negotiate)
    - [negotiateWith](#negotiatewith)
    - [htmlFile](#htmlfile)
    - [html](#html)
    - [renderHtml](#renderhtml)
    - [redirectTo](#redirectto)
    - [portRoute](#portroute)
    - [warbler](#warbler)
- [StatusCode HttpHandlers](#statuscode-httphandlers)
    - [Intermediate](#intermediate)
    - [Successful](#successful)
    - [RequestErrors](#requesterrors)
    - [ServerErrors](#servererrors)
- [Additional HttpHandlers](#additional-httphandlers)
    - [Giraffe.TokenRouter](#giraffetokenrouter)
        - [router](#router)
        - [routing functions](#routing-functions)
    - [Additional NuGet packages](#additional-nuget-packages)
- [Custom HttpHandlers](#custom-httphandlers)
- [Nested Response Writing](#nested-response-writing)
    - [WriteJsonAsync](#writejsonasync)
    - [WriteXmlAsync](#writexmlasync)
    - [WriteTextAsync](#writetextasync)
    - [RenderHtmlAsync](#renderhtmlasync)
    - [ReturnHtmlFileAsync](#returnhtmlfileasync)
- [Model Binding](#model-binding)
    - [BindJsonAsync](#bindjsonasync)
    - [BindXmlAsync](#bindxmlasync)
    - [BindFormAsync](#bindformasync)
    - [BindQueryString](#bindquerystring)
    - [BindModelAsync](#bindmodelasync)
- [Error Handling](#error-handling)
- [Sample applications](#sample-applications)
- [Benchmarks](#benchmarks)
- [Building and developing](#building-and-developing)
- [Contributing](#contributing)
- [Nightly builds and NuGet feed](#nightly-builds-and-nuget-feed)
- [Blog posts](#blog-posts)
- [Videos](#videos)
- [License](#license)
- [Contact and Slack Channel](#contact-and-slack-channel)

## About

[Giraffe](https://www.nuget.org/packages/Giraffe) is an F# micro web framework for building rich web applications. It has been heavily inspired and is similar to [Suave](https://suave.io/), but has been specifically designed with [ASP.NET Core](https://www.asp.net/core) in mind and can be plugged into the ASP.NET Core pipeline via [middleware](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/middleware). Giraffe applications are composed of so called `HttpHandler` functions which can be thought of a mixture of Suave's WebParts and ASP.NET Core's middleware.

If you'd like to learn more about the motivation of this project please read my [blog post on functional ASP.NET Core](https://dusted.codes/functional-aspnet-core) (some code samples in this blog post might be outdated today).

### Who is it for?

[Giraffe](https://www.nuget.org/packages/Giraffe) is intended for developers who want to build rich web applications on top of ASP.NET Core in a functional first approach. ASP.NET Core is a powerful web platform which has support by Microsoft and a huge developer community behind it and Giraffe is aimed at F# developers who want to benefit from that eco system.

It is not designed to be a competing web product which can be run standalone like NancyFx or Suave, but rather a lean micro framework which aims to complement ASP.NET Core where it comes short for functional developers. The fundamental idea is to build on top of the strong foundation of ASP.NET Core and re-use existing ASP.NET Core building blocks so F# developers can benefit from both worlds.

You can think of [Giraffe](https://www.nuget.org/packages/Giraffe) as the functional counter part of the ASP.NET Core MVC framework.

## Installation

### Using dotnet-new

The easiest way to get started with Giraffe is by installing the [`giraffe-template`](https://www.nuget.org/packages/giraffe-template) package, which adds a new template to your `dotnet new` command line tool:

```
dotnet new -i "giraffe-template::*"
```

Afterwards you can create a new Giraffe application by running `dotnet new giraffe`.

For more information about the Giraffe tempalte please visit the official [giraffe-template repository](https://github.com/giraffe-fsharp/giraffe-template).

### Doing it manually

Install the [Giraffe](https://www.nuget.org/packages/Giraffe) NuGet package:

```
PM> Install-Package Giraffe
```

Create a web application and plug it into the ASP.NET Core middleware:

```fsharp
open Giraffe

let webApp =
    choose [
        route "/ping"   >=> text "pong"
        route "/"       >=> htmlFile "/pages/index.html" ]

type Startup() =
    member __.Configure (app : IApplicationBuilder)
                        (env : IHostingEnvironment)
                        (loggerFactory : ILoggerFactory) =

        app.UseGiraffe webApp
```

## Basics

### HttpHandler

The main building block in Giraffe is a so called `HttpHandler`:

```fsharp
type HttpFuncResult = Task<HttpContext option>
type HttpFunc = HttpContext -> HttpFuncResult
type HttpHandler = HttpFunc -> HttpContext -> HttpFuncResult
```

A `HttpHandler` is a simple function which takes two curried arguments, a `HttpFunc` and a `HttpContext`, and returns a `HttpContext` (wrapped in an `option` and `Task` workflow) when finished.

Given that a `HttpHandler` receives and returns an ASP.NET Core `HttpContext` there is literally nothing which cannot be done from within a Giraffe web application which couldn't be done from a regular ASP.NET Core (MVC) application either.

Each `HttpHandler` can process an incoming `HttpRequest` before passing it further down the pipeline by invoking the next `HttpFunc` or short circuit the execution by returning an option of `Some HttpContext`.

If a `HttpHandler` decides to not process an incoming `HttpRequest` at all, then it can return `None` instead. In this case another `HttpHandler` might pick up the incoming `HttpRequest` or the middleware will defer to the next `RequestDelegate` from the ASP.NET Core pipeline.

The easiest way to get your head around a Giraffe `HttpHandler` is to think of it like a functional ASP.NET Core middleware. Each handler has the full `HttpContext` at its disposal and can decide whether it wants to return `Some HttpContext`, `None` or pass it on to the "next" `HttpFunc`.

Please check out the [sample applications](#sample-applications) for a demo as well as a real world example.

### Combinators

#### compose (>=>)

The `compose` combinator combines two `HttpHandler` functions into one:

```fsharp
let compose (handler1 : HttpHandler) (handler2 : HttpHandler) : HttpHandler =
    fun (next : HttpFunc) ->
        let func = next |> handler2 |> handler1
        fun (ctx : HttpContext) ->
            match ctx.Response.HasStarted with
            | true  -> next ctx
            | false -> func ctx
```

It is the main combinator as it allows composing many smaller `HttpHandler` functions into a bigger web application.

If you would like to learn more about the `>=>` (fish) operator then please check out [Scott Wlaschin's blog post on Railway oriented programming](http://fsharpforfunandprofit.com/posts/recipe-part2/).

##### Example:

```fsharp
let app = route "/" >=> setStatusCode 200 >=> text "Hello World"
```

#### choose

The `choose` combinator function iterates through a list of `HttpHandler` functions and invokes each individual handler until the first `HttpHandler` returns a result.

##### Example:

```fsharp
let app =
    choose [
        route "/foo" >=> text "Foo"
        route "/bar" >=> text "Bar"
    ]
```

### Tasks

Another important aspect to Giraffe is that it natively works with .NET's `Task` and `Task<'T>` objects instead of relying on F#'s `async {}` workflows. The main benefit of this is that it removes the necessity of converting back and forth between tasks and async workflows when building a Giraffe web application (because ASP.NET Core only works with tasks out of the box).

For this purpose Giraffe has it's own `task {}` workflow which comes with the `Giraffe.Tasks` NuGet package. Syntactically it works identical to F#'s async workflows:

```fsharp
open Giraffe.Tasks
open Giraffe.HttpHandlers

let personHandler =
    fun (next : HttpFunc) (ctx : HttpContext) ->
        task {
            let! person = ctx.BindModelAsync<Person>()
            return! json person next ctx
        }
```

The `task {}` workflow is not strictly tied to Giraffe and can also be used from other places in an F# application:

```fsharp
open Giraffe.Tasks

let readFileAndDoSomething (filePath : string) =
    task {
        use stream = new FileStream(filePath, FileMode.Open)
        use reader = new StreamReader(stream)
        let! contents = reader.ReadToEndAsync()

        // do something with contents

        return contents
    }
```

For more information please visit the official [Giraffe.Tasks](https://github.com/giraffe-fsharp/Giraffe.Tasks) GitHub repository.

## Default HttpHandlers

### GET, POST, PUT, PATCH, DELETE

`GET`, `POST`, `PUT`, `PATCH`, `DELETE` filters a request by the specified HTTP verb.

#### Example:

```fsharp
let app =
    choose [
        GET  >=> route "/foo" >=> text "GET Foo"
        POST >=> route "/foo" >=> text "POST Foo"
        route "/bar" >=> text "Always Bar"
    ]
```

### mustAccept

`mustAccept` filters a request by the `Accept` HTTP header. You can use it to check if a client accepts a certain mime type before returning a response.

#### Example:

```fsharp
let app =
    mustAccept [ "text/plain"; "application/json" ] >=>
        choose [
            route "/foo" >=> text "Foo"
            route "/bar" >=> json "Bar"
        ]
```

### challenge

`challenge` challenges an authentication with a specified authentication scheme (`authScheme`).

#### Example:

```fsharp
let mustBeLoggedIn =
    requiresAuthentication (challenge "Cookie")

let app =
    choose [
        route "/ping" >=> text "pong"
        route "/admin" >=> mustBeLoggedIn >=> text "You're an admin"
    ]
```

### signOff

`signOff` signs off the currently logged in user.

#### Example:

```fsharp
let app =
    choose [
        route "/ping" >=> text "pong"
        route "/logout" >=> signOff "Cookie" >=> text "You have successfully logged out."
    ]
```

### requiresAuthPolicy

`requiresauthpolicy` validates if a user satisfies policy requirement,
if not then the handler will execute the `authFailedHandler` function.

```fsharp
let mustBeJohn =
    requiresAuthPolicy (fun user -> user.HasClaim (ClaimTypes.Name, "John")) accessDenied

let app =
    choose [
        route "/ping" >=> text "pong"
        route "/john-only" >=> mustBeJohn >=> text "Hi John."
    ]
```

### requiresAuthentication

`requiresAuthentication` validates if a user is authenticated/logged in. If the user is not authenticated then the handler will execute the `authFailedHandler` function.

#### Example:

```fsharp
let mustBeLoggedIn =
    requiresAuthentication (challenge "Cookie")

let app =
    choose [
        route "/ping" >=> text "pong"
        route "/user" >=> mustBeLoggedIn >=> text "You're a logged in user."
    ]
```

### requiresRole

`requiresRole` validates if an authenticated user is in a specified role. If the user fails to be in the required role then the handler will execute the `authFailedHandler` function.

#### Example:

```fsharp
let accessDenied = setStatusCode 401 >=> text "Access Denied"

let mustBeAdmin =
    requiresAuthentication accessDenied
    >=> requiresRole "Admin" accessDenied

let app =
    choose [
        route "/ping" >=> text "pong"
        route "/admin" >=> mustBeAdmin >=> text "You're an admin."
    ]
```

### requiresRoleOf

`requiresRoleOf` validates if an authenticated user is in one of the supplied roles. If the user fails to be in one of the required roles then the handler will execute the `authFailedHandler` function.

#### Example:

```fsharp
let accessDenied = setStatusCode 401 >=> text "Access Denied"

let mustBeSomeAdmin =
    requiresAuthentication accessDenied
    >=> requiresRoleOf [ "Admin"; "SuperAdmin"; "RootAdmin" ] accessDenied

let app =
    choose [
        route "/ping" >=> text "pong"
        route "/admin" >=> mustBeSomeAdmin >=> text "You're an admin."
    ]
```

### clearResponse

`clearResponse` tries to clear the current response. This can be useful inside an error handler to reset the response before writing an error message to the body of the HTTP response object.

#### Example:

```fsharp
let errorHandler (ex : Exception) (logger : ILogger) =
    clearResponse
    >=> setStatusCode 500
    >=> text ex.Message

let webApp =
    choose [
        route "/foo" >=> text "Foo"
        route "/bar" >=> text "Bar"
    ]

type Startup() =
    member __.Configure (app : IApplicationBuilder)
                        (env : IHostingEnvironment)
                        (loggerFactory : ILoggerFactory) =
        app.UseGiraffeErrorHandler errorHandler
        app.UseGiraffe webApp
```

### route

`route` compares a given path with the actual request path and short circuits if it doesn't match.

#### Example:

```fsharp
let app =
    choose [
        route "/"    >=> text "Index path"
        route "/foo" >=> text "Foo"
        route "/bar" >=> text "Bar"
    ]
```

### routef

`routef` matches a given format string with the actual request path. On success it will resolve the arguments from the format string and invoke the given `HttpHandler` with them.

The following format placeholders are currently supported:

- `%b` for bool
- `%c` for char
- `%s` for string
- `%i` for int32
- `%d` for int64 (this is custom to Giraffe)
- `%f` for float/double

#### Example:

```fsharp
let app =
    choose [
        route  "/foo" >=> text "Foo"
        routef "/bar/%s/%i" (fun (name, age) ->
            // name is of type string
            // age is of type int
            text (sprintf "Name: %s, Age: %i" name age))
    ]
```

### routeCi

`routeCi` is the case insensitive version of `route`.

#### Example:

```fsharp
// "/FoO", "/fOO", "/bAr", etc. will match as well

let app =
    choose [
        routeCi "/"    >=> text "Index path"
        routeCi "/foo" >=> text "Foo"
        routeCi "/bar" >=> text "Bar"
    ]
```

### routeCif

`routeCif` is the case insensitive version of `routef`.

#### Example:

```fsharp
let app =
    choose [
        route  "/foo" >=> text "Foo"
        routeCif "/bar/%s/%i" (fun (name, age) ->
            text (sprintf "Name: %s, Age: %i" name age))
    ]
```

### routeBind

`routeBind` matches and parses a request path with a given object model. On success it will resolve the arguments from the route and create an instance of type `'T` and invoke the given
`HttpHandler` with it.

The `route` parameter of the `routeBind` handler can include any standard .NET Regex to allow greater flexibility when binding a route to an object model. For example `/{foo}/{bar}(/?)` specifies that the route may end with zero or one trailing slash when binding to the model.

#### Example:

```fsharp
type Person =
    {
        FirstName : string
        LastName : string

let app =
    choose [
        routeBind<Person> "/foo/{firstName}/{lastName}(/?)" (fun person ->
            sprintf "%s %s" person.FirstName person.LastName
            |> text)
    ]
    }

// HTTP GET /foo/John/Doe   --> Success
// HTTP GET /foo/John/Doe/  --> Success
// HTTP GET /foo/John/Doe// --> Failure

// The last case will not bind to the Person model,
// because the Regex doesn't allow more than one
// trailing slash (change ? to * and it will work).
```

### routeStartsWith

`routeStartsWith` checks if the current request path starts with the given string. This can be useful when combining with other http handlers, e.g. to validate a subset of routes for authentication.

#### Example:

```fsharp
let app =
    routeStartsWith "/api/" >=>
        requiresAuthentication (challenge "Cookie") >=>
            choose [
                route "/api/v1/foo" >=> text "Foo"
                route "/api/v1/bar" >=> text "Bar"
            ]
```

### routeStartsWithCi

`routeStartsWithCi` is the case insensitive version of `routeStartsWith`.

#### Example:

```fsharp
let app =
    routeStartsWithCi "/api/v1/" >=>
        choose [
            route "/api/v1/foo" >=> text "Foo"
            route "/api/v1/bar" >=> text "Bar"
        ]
```

### subRoute

`subRoute` checks if the current path begins with the given `path` and will invoke the passed in `handler` if it was a match. The given `handler` (and any nested handlers within it) should omit the already applied `path` for subsequent route evaluations.

#### Example:

```fsharp
let app =
    subRoute "/api"
        (choose [
            subRoute "/v1"
                (choose [
                    route "/foo" >=> text "Foo 1"
                    route "/bar" >=> text "Bar 1" ])
            subRoute "/v2"
                (choose [
                    route "/foo" >=> text "Foo 2"
                    route "/bar" >=> text "Bar 2" ]) ])
```

### subRouteCi

`subRouteCi` is the case insensitive version of `subRoute`.

#### Example:

```fsharp
let app =
    subRouteCi "/api"
        (choose [
            subRouteCi "/v1"
                (choose [
                    route "/foo" >=> text "Foo 1"
                    route "/bar" >=> text "Bar 1" ])
            subRouteCi "/v2"
                (choose [
                    route "/foo" >=> text "Foo 2"
                    route "/bar" >=> text "Bar 2" ]) ])
```

### setStatusCode

`setStatusCode` changes the status code of the `HttpResponse`.

#### Example:

```fsharp
let app =
    choose [
        route  "/foo" >=> text "Foo"
        setStatusCode 404 >=> text "Not found"
    ]
```

### setHttpHeader

`setHttpHeader` sets or modifies a HTTP header of the `HttpResponse`.

#### Example:

```fsharp
let app =
    choose [
        route  "/foo" >=> text "Foo"
        setStatusCode 404 >=> setHttpHeader "X-CustomHeader" "something" >=> text "Not found"
    ]
```

### setBody

`setBody` sets or modifies the body of the `HttpResponse`. This http handler triggers a response to the client and other http handlers will not be able to modify the HTTP headers afterwards any more.

#### Example:

```fsharp
let app =
    choose [
        route  "/foo" >=> setBody (Encoding.UTF8.GetBytes "Some string")
    ]
```

### setBodyAsString

`setBodyAsString` sets or modifies the body of the `HttpResponse`. This http handler triggers a response to the client and other http handlers will not be able to modify the HTTP headers afterwards any more.

#### Example:

```fsharp
let app =
    choose [
        route  "/foo" >=> setBodyAsString "Some string"
    ]
```

### text

`text` sets or modifies the body of the `HttpResponse` by sending a plain text value to the client.. This http handler triggers a response to the client and other http handlers will not be able to modify the HTTP headers afterwards any more.

The different between `text` and `setBodyAsString` is that this http handler also sets the `Content-Type` HTTP header to `text/plain`.

#### Example:

```fsharp
let app =
    choose [
        route  "/foo" >=> text "Some string"
    ]
```

You can also use the [`WriteTextAsync`](#writetextasync) extension method to return a plain text response back to the client.

### customJson

`customJson` sets or modifies the body of the `HttpResponse` by sending a JSON serialized object with custom `JsonSerializerSettings` to the client. This http handler triggers a response to the client and other http handlers will not be able to modify the HTTP headers afterwards any more. It also sets the `Content-Type` HTTP header to `application/json`.

#### Example:

```fsharp
type Person =
    {
        FirstName : string
        LastName  : string
    }

let settings = JsonSerializerSettings(
        Formatting = Formatting.Indented,
        NullValueHandling = NullValueHandling.Ignore
    )

let app =
    choose [
        route  "/foo" >=> customJson settings { FirstName = "Foo"; LastName = "Bar" }
    ]
```

You can also create a new http handler with the help of `customJson`:

```fsharp
type Person =
    {
        FirstName : string
        LastName  : string
    }

let settings = JsonSerializerSettings(
        Formatting = Formatting.Indented,
        NullValueHandling = NullValueHandling.Ignore
    )

let formattedJson = customJson settings

let app =
    choose [
        route  "/foo" >=> formattedJson { FirstName = "Foo"; LastName = "Bar" }
    ]
```

Alternatively you can also use the [`WriteJsonAsync`](#writejsonasync) extension method to return a custom serialized JSON response back to the client.

### json

`json` sets or modifies the body of the `HttpResponse` by sending a JSON serialized object to the client. This http handler triggers a response to the client and other http handlers will not be able to modify the HTTP headers afterwards any more. It also sets the `Content-Type` HTTP header to `application/json`.

#### Example:

```fsharp
type Person =
    {
        FirstName : string
        LastName  : string
    }

let app =
    choose [
        route  "/foo" >=> json { FirstName = "Foo"; LastName = "Bar" }
    ]
```

You can also use the [`WriteJsonAsync`](#writejsonasync) extension method to return a default serialized JSON response back to the client.

### xml

`xml` sets or modifies the body of the `HttpResponse` by sending an XML serialized object to the client. This http handler triggers a response to the client and other http handlers will not be able to modify the HTTP headers afterwards any more. It also sets the `Content-Type` HTTP header to `application/xml`.

#### Example:

```fsharp
[<CLIMutable>]
type Person =
    {
        FirstName : string
        LastName  : string
    }

let app =
    choose [
        route  "/foo" >=> xml { FirstName = "Foo"; LastName = "Bar" }
    ]
```

You can also use the [`WriteXmlAsync`](#writexmlasync) extension method to return an XML response back to the client.

### negotiate

`negotiate` sets or modifies the body of the `HttpResponse` by inspecting the `Accept` header of the HTTP request and deciding if the response should be sent in JSON or XML or plain text. If the client is indifferent then the default response will be sent in JSON.

This http handler triggers a response to the client and other http handlers will not be able to modify the HTTP headers afterwards any more.

#### Example:

```fsharp
[<CLIMutable>]
type Person =
    {
        FirstName : string
        LastName  : string
    }
    // The ToString method is used to serialize the object as text/plain during content negotiation
    override this.ToString() =
        sprintf "%s %s" this.FirstName this.LastNam

let app =
    choose [
        route  "/foo" >=> negotiate { FirstName = "Foo"; LastName = "Bar" }
    ]
```

### negotiateWith

`negotiateWith` sets or modifies the body of the `HttpResponse` by inspecting the `Accept` header of the HTTP request and deciding in what mimeType the response should be sent. A dictionary of type `IDictionary<string, obj -> HttpHandler>` is used to determine which `obj -> HttpHandler` function should be used to convert an object into a `HttpHandler` for a given mime type.

This http handler triggers a response to the client and other http handlers will not be able to modify the HTTP headers afterwards any more.

#### Example:

```fsharp
[<CLIMutable>]
type Person =
    {
        FirstName : string
        LastName  : string
    }

// xml and json are the two HttpHandler functions from above
let rules =
    dict [
        "*/*"             , xml
        "application/json", json
        "application/xml" , xml
    ]

let app =
    choose [
        route  "/foo" >=> negotiateWith rules { FirstName = "Foo"; LastName = "Bar" }
    ]
```

### htmlFile

`htmlFile` sets or modifies the body of the `HttpResponse` with the contents of a physical html file. This http handler triggers a response to the client and other http handlers will not be able to modify the HTTP headers afterwards any more.

This http handler takes a rooted path of a html file or a path which is relative to the ContentRootPath as the input parameter and sets the HTTP header `Content-Type` to `text/html`.

#### Example:

```fsharp
let app =
    choose [
        route  "/" >=> htmlFile "index.html"
    ]
```

### html

`html` sets or modifies the body of the `HttpResponse` with the contents of a single string variable. This http handler triggers a response to the client and other http handlers will not be able to modify the HTTP headers afterwards any more.

#### Example:

```fsharp
let app =
    choose [
        route  "/" >=> html "<html><head><title>Hello World</title></head><body><p>Hello World</p></body></html>"
    ]
```

### renderHtml

`renderHtml` is a more functional way of generating HTML by composing HTML elements in F# to generate a rich Model-View output.

It is based on [Suave's Experimental Html](https://github.com/SuaveIO/suave/blob/master/src/Experimental/Html.fs) and bears some resemblance with [Elm](http://elm-lang.org/examples).

#### Example:
Create a function that accepts a model and returns an `XmlNode`:

```fsharp
open Giraffe.GiraffeViewEngine
open Giraffe.GiraffeViewEngine.Attributes

let model = { Name = "John Doe" }

let layout (content: XmlNode list) =
    html [] [
        head [] [
            title [] (encodedText "Giraffe")
        ]
        body [] content
    ]

let partial () =
    p [] (encodedText "Some partial text.")

let personView model =
    [
        div [``class`` "container"] [
                h3 [``title_attr`` "Some title attribute"] (sprintf "Hello, %s" model.Name |> encodedText)
                a [href "https://github.com/giraffe-fsharp/Giraffe"] [encodedText "Github"]
            ]
        div [] [partial()]
    ] |> layout

let app =
    choose [
        route "/" >=> (personView model |> renderHtml)
    ]
```

### redirectTo

`redirectTo` uses a 302 or 301 (when permanent) HTTP response code to redirect the client to the specified location. It takes in two parameters, a boolean flag denoting whether the redirect should be permanent or not and the location to redirect to.

#### Example:

```fsharp
let app =
    choose [
        route "/"          >=> redirectTo false "/foo"
        route "/permanent" >=> redirectTo true "http://example.org"
        route "/foo"       >=> text "Some string"
    ]
```

### portRoute

If your web server is listening to multiple ports through `WebHost.UseUrls` then you can use the `portRoute` HttpHandler to easily filter incoming requests based on their port by providing a list of port number and HttpHandler (`(int * HttpHandler) list`).

#### Example
```fsharp

let app9001 =
    router notFound [
        GET [
            route  "/index1" => text "index page1" ]
    ]

let app9002 =
    router notFound [
        POST [
            subRoute "/api2" [
                route "/newpassword2" => text "newpassword2" ]
        ]
    ]

let app = portRoute [
    (9001, app9001)
    (9002, app9002)
]

```

### warbler

If your route is not returning a static response, then you should wrap your function with a warbler.

#### Example
```fsharp
// unit -> string
let time() =
    System.DateTime.Now.ToString()

let webApp =
    choose [
        GET >=>
            choose [
                route "/once"      >=> (time() |> text)
                route "/everytime" >=> warbler (fun _ -> (time() |> text))
            ]
    ]
```

Functions in F# are eagerly evaluated and the `/once` route will only be evaluated the first time.
A warbler will help to evaluate the function every time the route is hit.

```fsharp
// ('a -> 'a -> 'b) -> 'a -> 'b
let warbler f a = f a a
```

## StatusCode HttpHandlers

Giraffe also offers a default set of so called `HttpStatusCodeHandlers`, which can be used to return a response with a specific HTTP status code.

If you need to set the HTTP status code as part of a custom `HttpHandler` then please use the [`setStatusCode`](#setstatuscode) handler instead.

Giraffe's default set of `HttpStatusCodeHandlers` are categorised in four sub modules:

- [Intermediate](#intermediate) (1xx status codes)
- [Successful](#successful) (2xx status codes)
- [RequestErrors](#requesterrors) (4xx status codes)
- [ServerErrors](#servererrors) (5xx status codes)

For most `HttpStatusCodeHandlers` (except `Intermediate`) there are two available function versions - a lower case and an upper case version.

The lower case version (e.g. `Successful.ok`) is the lower level function which let's you combine it with any other `HttpHandler`:

Example:

```fsharp
let app = route `/` >=> Successful.ok (text "Hello World")
```

This is essentially the equivalent of:

```fsharp
let app = route `/` >=> setStatusCode 200 >=> text "Hello World"
```

The upper case version (e.g. `Successful.OK`) can be used to return an object back to the client through Giraffe's deafult content negotiation.

Example:

```fsharp
type Person = { FirstName : string; LastName : string }

let johnDoe = { FirstName = "John"; LastName = "Doe" }

let app = choose [
    route `/`     >=> Successful.OK "Hello World"
    route `/john` >=> Successful.OK johnDoe
]
```

In order to better explain the upper case version you could equally write the same code this way:

```fsharp
type Person = { FirstName : string; LastName : string }

let johnDoe = { FirstName = "John"; LastName = "Doe" }

let app = choose [
    route `/`     >=> setStatusCode 200 >=> negotiate "Hello World"
    route `/john` >=> setStatusCode 200 >=> negotiate johnDoe
]
```

For HTTP 3xx status codes it is recommended to use the [redirectTo](#redirectto) http handler.

### Intermediate

| HTTP Status Code | Function name | Example |
| ---------------- | ------------- | ------- |
| 100 | CONTINUE | `route "/" >=> Intermediate.CONTINUE` |
| 101 | SWITCHING_PROTO | `route "/" >=> Intermediate.SWITCHING_PROTO` |

### Successful

| HTTP Status Code | Function name | Example |
| ---------------- | ------------- | ------- |
| 200 | ok | `route "/" >=> Successful.ok (text "Hello World")` |
| 200 | OK | `route "/" >=> Successful.OK "Hello World"` |
| 201 | created | `route "/" >=> Successful.created (json someObj)` |
| 201 | CREATED | `route "/" >=> Successful.CREATED someObj` |
| 202 | accepted | `route "/" >=> Successful.accepted (xml someObj)` |
| 202 | ACCEPTED | `route "/" >=> Successful.ACCEPTED someObj` |

### RequestErrors

| HTTP Status Code | Function name | Example |
| ---------------- | ------------- | ------- |
| 400 | badRequest | `route "/" >=> RequestErrors.badRequest (text "Don't like it")` |
| 400 | BAD_REQUEST | `route "/" >=> RequestErrors.BAD_REQUEST "Don't like it"` |
| 401 | unauthorized | `route "/" >=> RequestErrors.unauthorized "Basic" "MyApp" (text "Don't know who you are")` |
| 401 | UNAUTHORIZED | `route "/" >=> RequestErrors.UNAUTHORIZED "Don't know who you are"` |
| 403 | forbidden | `route "/" >=> RequestErrors.forbidden (text "Not enough permissions")` |
| 403 | FORBIDDEN | `route "/" >=> RequestErrors.FORBIDDEN "Not enough permissions"` |
| 404 | notFound | `route "/" >=> RequestErrors.notFound (text "Page not found")` |
| 404 | NOT_FOUND | `route "/" >=> RequestErrors.NOT_FOUND "Page not found"` |
| 405 | methodNotAllowed | `route "/" >=> RequestErrors.methodNotAllowed (text "Don't support this")` |
| 405 | METHOD_NOT_ALLOWED | `route "/" >=> RequestErrors.METHOD_NOT_ALLOWED "Don't support this"` |
| 406 | notAcceptable | `route "/" >=> RequestErrors.notAcceptable (text "Not having this")` |
| 406 | NOT_ACCEPTABLE | `route "/" >=> RequestErrors.NOT_ACCEPTABLE "Not having this"` |
| 409 | conflict | `route "/" >=> RequestErrors.conflict (text "some conflict")` |
| 409 | CONFLICT | `route "/" >=> RequestErrors.CONFLICT "some conflict"` |
| 410 | gone | `route "/" >=> RequestErrors.gone (text "Too late, not here anymore")` |
| 410 | GONE | `route "/" >=> RequestErrors.GONE "Too late, not here anymore"` |
| 415 | unsupportedMediaType | `route "/" >=> RequestErrors.unsupportedMediaType (text "Please send in different format")` |
| 415 | UNSUPPORTED_MEDIA_TYPE | `route "/" >=> RequestErrors.UNSUPPORTED_MEDIA_TYPE "Please send in different format"` |
| 422 | unprocessableEntity | `route "/" >=> RequestErrors.unprocessableEntity (text "Can't do anything with this")` |
| 422 | UNPROCESSABLE_ENTITY | `route "/" >=> RequestErrors.UNPROCESSABLE_ENTITY "Can't do anything with this"` |
| 428 | preconditionRequired | `route "/" >=> RequestErrors.preconditionRequired (test "Please do something else first")` |
| 428 | PRECONDITION_REQUIRED | `route "/" >=> RequestErrors.PRECONDITION_REQUIRED "Please do something else first"` |
| 429 | tooManyRequests | `route "/" >=> RequestErrors.tooManyRequests (text "Slow down champ")` |
| 429 | TOO_MANY_REQUESTS | `route "/" >=> RequestErrors.TOO_MANY_REQUESTS "Slow down champ"` |

Note that the `unauthorized` and `UNAUTHORIZED` functions require two additional parameters, an [authentication scheme](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#Authentication_schemes) and a realm.

### ServerErrors

| HTTP Status Code | Function name | Example |
| ---------------- | ------------- | ------- |
| 500 | internalError | `route "/" >=> ServerErrors.internalError (text "Ops, something went wrong")` |
| 500 | INTERNAL_ERROR | `route "/" >=> ServerErrors.INTERNAL_ERROR "Not implemented"` |
| 501 | notImplemented | `route "/" >=> ServerErrors.notImplemented (text "Not implemented")` |
| 501 | NOT_IMPLEMENTED | `route "/" >=> ServerErrors.NOT_IMPLEMENTED "Ops, something went wrong"` |
| 502 | badGateway | `route "/" >=> ServerErrors.badGateway (text "Bad gateway")` |
| 502 | BAD_GATEWAY | `route "/" >=> ServerErrors.BAD_GATEWAY "Bad gateway"` |
| 503 | serviceUnavailable | `route "/" >=> ServerErrors.serviceUnavailable (text "Service unavailable")` |
| 503 | SERVICE_UNAVAILABLE | `route "/" >=> ServerErrors.SERVICE_UNAVAILABLE "Service unavailable"` |
| 504 | gatewayTimeout | `route "/" >=> ServerErrors.gatewayTimeout (text "Gateway timeout")` |
| 504 | GATEWAY_TIMEOUT | `route "/" >=> ServerErrors.GATEWAY_TIMEOUT "Gateway timeout"` |
| 505 | invalidHttpVersion | `route "/" >=> ServerErrors.invalidHttpVersion (text "Invalid HTTP version")` |

## Additional HttpHandlers

There's a few additional `HttpHandler` functions which you can get through referencing extra modules or NuGet packages.

### Giraffe.TokenRouter

The `Giraffe.TokenRouter` module adds alternative `HttpHandler` functions to route incoming HTTP requests through a basic [Radix Tree](https://en.wikipedia.org/wiki/Radix_tree). Several routing handlers (e.g.: `routef` and `subRoute`) have been overridden in such a way that path matching and value parsing are significantly faster than using the basic `choose` function.

This implementation assumes that additional memory and compilation time is not an issue. If speed and performance of parsing and path matching is required then the `Giraffe.TokenRouter` is the preferred option.

#### router

The base of all routing decisions is a `router` function instead of the default `choose` function when using the `Giraffe.TokenRouter` module.

The `router` HttpHandler takes two arguments, a `HttpHandler` to execute when no route can be matched (typical 404 Not Found handler) and secondly a list of all routing functions.

##### Example:

Defining a basic router and routes

```fsharp
let notFound = setStatusCode 404 >=> text "Not found"
let app =
    router notFound [
        route "/"       (text "index")
        route "/about"  (text "about")
    ]
```

#### routing functions

When using the `Giraffe.TokenRouter` module the main routing functions have been slightly overridden to match the alternative (speed improved) implementation.

The `route` and `routef` handlers work the exact same way as before, except that the continuation handler needs to be enclosed in parentheses or captured by the `<|` or `=>` operators.

The http handlers `GET`, `POST`, `PUT` and `DELETE` are functions which take a list of nested http handler functions similar to before.

The `subRoute` handler has been altered in order to accept an additional parameter of child routing functions. All child routing functions will presume that the given sub path has been prepended.

### Example:

Defining a basic router and routes

```fsharp
let notFound = setStatusCode 404 >=> text "Not found"
let app =
    router notFound [
        route "/"       (text "index")
        route "/about"  (text "about")
        routef "parsing/%s/%i" (fun (s,i) -> text (sprintf "Recieved %s & %i" s i))
        subRoute "/api" [
            GET [
                route "/"       (text "api index")
                route "/about"  (text "api about")
                subRoute "/v2" [
                    route "/"       (text "api v2 index")
                    route "/about"  (text "api v2 about")
                ]
            ]

        ]
    ]
```

### Additional NuGet packages

There's more `HttpHandler` functions available through additional NuGet packages:

- [Giraffe.Razor](https://github.com/giraffe-fsharp/Giraffe.Razor): Adds native Razor view functionality to Giraffe web applications.
- [Giraffe.DotLiquid](https://github.com/giraffe-fsharp/Giraffe.DotLiquid): Adds native DotLiquid template functionality to Giraffe web applications.

## Custom HttpHandlers

Defining a new `HttpHandler` is fairly easy. All you need to do is to create a new function which matches the signature of `HttpFunc -> HttpContext -> Task<HttpContext option>`. Through currying your custom `HttpHandler` can extend the original signature as long as the partial application of your function will still return a function of `HttpFunc -> HttpContext -> Task<HttpContext option>` (`HttpFunc -> HttpFunc`).

### Example:

Defining a custom HTTP handler to partially filter a route:

*(After creating this example I added the `routeStartsWith` HttpHandler to the list of default handlers as it turned out to be quite useful)*

```fsharp
let routeStartsWith (subPath : string) =
    fun (next : HttpFunc) (ctx : HttpContext) ->
        if ctx.Request.Path.ToString().StartsWith subPath
        then next ctx
        else Task.FromResult None
```

Defining another custom HTTP handler to validate a mandatory HTTP header:

```fsharp
let requiresToken (expectedToken : string) (handler : HttpHandler) =
    fun (next : HttpFunc) (ctx : HttpContext) ->
        let token    = ctx.Request.Headers.["X-Token"].ToString()
        let response =
            if token.Equals(expectedToken)
            then handler
            else setStatusCode 401 >=> text "Token wrong or missing"
        response next ctx
```

Composing a web application from smaller HTTP handlers:

```fsharp
let app =
    choose [
        route "/"       >=> htmlFile "index.html"
        route "/about"  >=> htmlFile "about.html"
        routeStartsWith "/api/v1/" >=>
            requiresToken "secretToken" (
                choose [
                    route "/api/v1/foo" >=> text "something"
                    route "/api/v1/bar" >=> text "bar"
                ]
            )
        setStatusCode 404 >=> text "Not found"
    ] : HttpHandler
```

## Nested Response Writing

The `Giraffe.HttpContextExtensions` module exposes a default set of response writing functions which extend the `HttpContext` object. Instead of using the [`customJson`](#customjson), [`json`](#json), [`xml`](#xml), or [`text`](#text) handlers to compose a custom HttpHandler you can also use the `WriteJsonAsync`, `WriteXmlAsync` and `WriteTextAsync` extension methods to directly write to the response of the `HttpContext` and close the pipeline.

### WriteJsonAsync

`ctx.WriteJsonAsync someObj` can be used to return a JSON response back to the client. Alternatively you can use `ctx.WriteJsonAsync (settings : JsoSerializerSettings) someObj` to customize the generated JSON before sending the response back to the client.

#### Example:

```fsharp
[<CLIMutable>]
type Person =
    {
        FirstName : string
        LastName  : string
    }

let myJsonHandler : HttpHandler =
    fun next ctx ->
        let person = { FirstName = "Foo"; LastName = "Bar" }
        ctx.WriteJsonAsync person

let app =
    choose [
        route "/json" >=> myJsonHandler
    ]
```

### WriteXmlAsync

`ctx.WriteXmlAsync someObj` can be used to return an XML response back to the client.

#### Example:

```fsharp
[<CLIMutable>]
type Person =
    {
        FirstName : string
        LastName  : string
    }

let myXmlHandler : HttpHandler =
    fun next ctx ->
        let person = { FirstName = "Foo"; LastName = "Bar" }
        ctx.WriteXmlAsync person

let app =
    choose [
        route "/xml" >=> myXmlHandler
    ]
```

### WriteTextAsync

`ctx.WriteTextAsync "some text"` can be used to return a plain text response back to the client.

#### Example:

```fsharp
let myTextHandler : HttpHandler =
    fun next ctx ->
        let str = "Hello World"
        ctx.WriteTextAsync str

let app =
    choose [
        route "/text" >=> myTextHandler
    ]
```

### RenderHtmlAsync

`ctx.RenderHtmlAsync someNode` can be used to return a [GiraffeViewEngine](#renderhtmlasync) node.

#### Example:

```fsharp
let myHtmlHandler =
    fun (next: HttpFunc) (ctx: HttpContext) ->
        let htmlDoc =
            html [] [
                head [] []
                body [] [
                    h1 [] [EncodedText "Hello world"]
                ]
            ]
        ctx.RenderHtmlAsync(htmlDoc)

let app =
    choose [
        route "/html" >=> myHtmlHandler
    ]
```

### ReturnHtmlFileAsync

`ctx.ReturnHtmlFileAsync "./myPage.html"` can be used to return a html file. Note that the path should be relative, similar to [htmlFile](#htmlfile).

#### Example:

```fsharp
let htmlFileHandler  =
    fun (next:HttpFunc) (ctx:HttpContext) ->
        ctx.ReturnHtmlFileAsync "./index.html"

let app =
    choose [
        route "/htmlFile" >=> htmlFileHandler
    ]
```

## Model Binding

The `Giraffe.HttpContextExtensions` module exposes a default set of model binding functions which extend the `HttpContext` object.

### BindJsonAsync

`ctx.BindJsonAsync<'T>()` can be used to bind a JSON payload to a strongly typed model. Alternatively you can pass in an additional object of type `JsonSerializerSettings` to customize the JSON deserialisation during model binding.

#### Example

Define an F# record type with the `CLIMutable` attribute which will add a parameterless constructor to the type:

```fsharp
[<CLIMutable>]
type Car =
    {
        Name   : string
        Make   : string
        Wheels : int
        Built  : DateTime
    }
```

Then create a new `HttpHandler` which uses `BindJsonAsync` and use it from an app:

```fsharp
open Giraffe.HttpHandlers
open Giraffe.HttpContextExtensions

let submitCar =
    fun (next : HttpFunc) (ctx : HttpContext) ->
        task {
            // Binds a JSON payload to a Car object
            let! car = ctx.BindJsonAsync<Car>()

            // Serializes the Car object back into JSON
            // and sends it back as the response.
            return! json car next ctx
        }

let webApp =
    choose [
        GET >=>
            choose [
                route "/"    >=> text "index"
                route "ping" >=> text "pong" ]
        POST >=> route "/car" >=> submitCar ]
```

You can test the bind function by sending a HTTP request with a JSON payload:

```
POST http://localhost:5000/car HTTP/1.1
Host: localhost:5000
Connection: keep-alive
Content-Length: 77
Cache-Control: no-cache
Content-Type: application/json
Accept: */*

{ "name": "DB9", "make": "Aston Martin", "wheels": 4, "built": "2016-01-01" }
```

### bindXmlAsync

`ctx.BindXmlAsync<'T>()` can be used to bind an XML payload to a strongly typed model.

#### Example

Define an F# record type with the `CLIMutable` attribute which will add a parameterless constructor to the type:

```fsharp
[<CLIMutable>]
type Car =
    {
        Name   : string
        Make   : string
        Wheels : int
        Built  : DateTime
    }
```

Then create a new `HttpHandler` which uses `BindXmlAsync` and use it from an app:

```fsharp
open Giraffe.HttpHandlers
open Giraffe.HttpContextExtensions

let submitCar =
    fun (next : HttpFunc) (ctx : HttpContext) ->
        task {
            // Binds an XML payload to a Car object
            let! car = ctx.BindXmlAsync<Car>()

            // Serializes the Car object back into JSON
            // and sends it back as the response.
            return! json car next ctx
        }

let webApp =
    choose [
        GET >=>
            choose [
                route "/"    >=> text "index"
                route "ping" >=> text "pong" ]
        POST >=> route "/car" >=> submitCar ]
```

You can test the bind function by sending a HTTP request with an XML payload:

```
POST http://localhost:5000/car HTTP/1.1
Host: localhost:5000
Connection: keep-alive
Content-Length: 104
Cache-Control: no-cache
Content-Type: application/xml
Accept: */*

<Car>
    <Name>DB9</Name>
    <Make>Aston Martin</Make>
    <Wheels>4</Wheels>
    <Built>2016-01-01</Built>
</Car>
```

### BindFormAsync

`ctx.BindFormAsync<'T>(?cultureInfo : CultureInfo)` can be used to bind a form urlencoded payload to a strongly typed model.

#### Example

Define an F# record type with the `CLIMutable` attribute which will add a parameterless constructor to the type:

```fsharp
[<CLIMutable>]
type Car =
    {
        Name   : string
        Make   : string
        Wheels : int
        Built  : DateTime
    }
```

Then create a new `HttpHandler` which uses `BindFormAsync` and use it from an app:

```fsharp
open Giraffe.HttpHandlers
open Giraffe.HttpContextExtensions

let submitCar =
    fun (next : HttpFunc) (ctx : HttpContext) ->
        task {
            // Binds a form urlencoded payload to a Car object
            let! car = ctx.BindFormAsync<Car>()

            // Serializes the Car object back into JSON
            // and sends it back as the response.
            return! json car next ctx
        }

let webApp =
    choose [
        GET >=>
            choose [
                route "/"    >=> text "index"
                route "ping" >=> text "pong" ]
        POST >=> route "/car" >=> submitCar ]
```

You can also specify a `CultureInfo` parameter when binding from a form:

```fsharp
let british = CultureInfo.CreateSpecificCulture("en-GB")
let! car = ctx.BindFormAsync<Car> british
```

You can test the bind function by sending a HTTP request with a form payload:

```
POST http://localhost:5000/car HTTP/1.1
Host: localhost:5000
Connection: keep-alive
Content-Length: 52
Cache-Control: no-cache
Content-Type: application/x-www-form-urlencoded
Accept: */*

Name=DB9&Make=Aston+Martin&Wheels=4&Built=2016-01-01
```

### bindQueryString

`ctx.BindQueryString<'T>(?cultureInfo : CultureInfo)` can be used to bind a query string to a strongly typed model.

#### Example

Define an F# record type with the `CLIMutable` attribute which will add a parameterless constructor to the type:

```fsharp
[<CLIMutable>]
type Car =
    {
        Name   : string
        Make   : string
        Wheels : int
        Built  : DateTime
    }
```

Then create a new `HttpHandler` which uses `BindQueryString` and use it from an app:

```fsharp
open Giraffe.HttpHandlers
open Giraffe.HttpContextExtensions

let submitCar =
    fun (next : HttpFunc) (ctx : HttpContext) ->
        task {
            // Binds a query string to a Car object
            let car = ctx.BindQueryString<Car>()

            // Serializes the Car object back into JSON
            // and sends it back as the response.
            return! json car next ctx
        }

let webApp =
    choose [
        GET >=>
            choose [
                route "/"    >=> text "index"
                route "ping" >=> text "pong"
                route "/car" >=> submitCar ]
```

You can also specify a `CultureInfo` parameter when binding from a query string:

```fsharp
let british = CultureInfo.CreateSpecificCulture("en-GB")
let car = ctx.BindQueryString<Car> british
```

You can test the bind function by sending a HTTP request with a query string:

```
GET http://localhost:5000/car?Name=Aston%20Martin&Make=DB9&Wheels=4&Built=1990-04-20 HTTP/1.1
Host: localhost:5000
Cache-Control: no-cache
Accept: */*

```

### BindModelAsync

`ctx.BindModelAsync<'T>(?cultureInfo : CultureInfo)` can be used to automatically detect the method and `Content-Type` of a HTTP request and automatically bind a JSON, XML,or form urlencoded payload or a query string to a strongly typed model. Alternatively you can pass in an additional object of type `JsonSerializerSettings` to customize the JSON deserializer during model binding and/or a `CultureInfo` object.

#### Example

Define an F# record type with the `CLIMutable` attribute which will add a parameterless constructor to the type:

```fsharp
[<CLIMutable>]
type Car =
    {
        Name   : string
        Make   : string
        Wheels : int
        Built  : DateTime
    }
```

Then create a new `HttpHandler` which uses `BindModelAsync` and use it from an app:

```fsharp
open Giraffe.HttpHandlers
open Giraffe.HttpContextExtensions

let submitCar =
    fun (next : HttpFunc) (ctx : HttpContext) ->
        task {
            // Binds a JSON, XML or form urlencoded payload to a Car object
            let! car = ctx.BindModelAsync<Car>()

            // Serializes the Car object back into JSON
            // and sends it back as the response.
            return! json car next ctx
        }

let webApp =
    choose [
        GET >=>
            choose [
                route "/"    >=> text "index"
                route "ping" >=> text "pong" ]
        // Can accept GET and POST requests and
        // bind a model from the payload or query string
        route "/car" >=> submitCar ]
```

You can also specify a `CultureInfo` parameter when using `BindModelAsync`:

```fsharp
let british = CultureInfo.CreateSpecificCulture("en-GB")
let! car = ctx.BindModelAsync<Car> british
```

## Error Handling

Similar to building a web application in Giraffe you can also set a global error handler, which can react to any unhandled exception of your web application.

The `ErrorHandler` is a function which accepts an exception object and a default logger and returns a `HttpHandler` function which is the same as all other `HttpHandler` functions in Giraffe:

```fsharp
type ErrorHandler = exn -> ILogger -> HttpHandler
```

For example you could create an error handler which logs the unhandled exception and returns a HTTP 500 response with the error message as plain text:

```fsharp
let errorHandler (ex : Exception) (logger : ILogger) =
    logger.LogError(EventId(), ex, "An unhandled exception has occurred while executing the request.")
    clearResponse
    >=> setStatusCode 500
    >=> text ex.Message
```

In order to enable the error handler you have to configure the error handler in your application startup:

```fsharp
type Startup() =
    member __.Configure (app : IApplicationBuilder)
                        (env : IHostingEnvironment)
                        (loggerFactory : ILoggerFactory) =
        app.UseGiraffeErrorHandler errorHandler
        app.UseGiraffe webApp
```

It is recommended to set the error handler as the first middleware in the pipeline, so that any unhandled exception from a later middleware can be caught and processed by the error handling function.

## Sample applications

### Demo apps

There are three basic sample applications in the [`/samples`](https://github.com/giraffe-fsharp/Giraffe/tree/develop/samples) folder. The [IdentityApp](https://github.com/giraffe-fsharp/Giraffe/tree/develop/samples/IdentityApp) demonstrates how ASP.NET Core Identity can be used with Giraffe, the [JwtApp](https://github.com/giraffe-fsharp/Giraffe/tree/develop/samples/JwtApp) shows how to configure JWT tokens in Giraffe and the [SampleApp](https://github.com/giraffe-fsharp/Giraffe/tree/develop/samples/SampleApp) is a generic sample application covering multiple features.

### Live apps

An example of a live website which uses Giraffe is [https://buildstats.info](https://buildstats.info). It uses the [GiraffeViewEngine](#renderhtml) to build dynamically rich SVG images and Docker to run the application in the Google Container Engine (see [GitHub repository](https://github.com/dustinmoris/CI-BuildStats)).

More sample applications will be added in the future.

## Benchmarks

Currently Giraffe has only been tested against a simple plain text route and measured the total amount of handled requests per second. The latest result yielded an average of 79093 req/s over a period of 10 seconds, which was only closely after plain Kestrel which was capable of handling 79399 req/s on average.

Please check out [Jimmy Byrd](https://github.com/TheAngryByrd)'s [dotnet-web-benchmarks](https://github.com/TheAngryByrd/dotnet-web-benchmarks) for more details.

## Building and developing

Giraffe is built with the latest [.NET Core SDK](https://www.microsoft.com/net/download/core).

You can either install [Visual Studio 2017](https://www.visualstudio.com/vs/) which comes with the latest SDK or manually download and install the [.NET SDK 2.0](https://www.microsoft.com/net/download/core).

After installation you should be able to run the `.\build.ps1` script to successfully build, test and package the library.

The build script supports the following flags:

- `-IncludeTests` will build and run the tests project as well
- `-IncludeSamples` will build and test the samples project as well
- `-All` will build and test all projects
- `-Release` will build Giraffe with the `Release` configuration
- `-Pack` will create a NuGet package for Giraffe and giraffe-template.
- `-OnlyNetStandard` will build Giraffe only targeting the NETStandard1.6 framework

Examples:

Only build the Giraffe project in `Debug` mode:
```
PS > .\build.ps1
```

Build the Giraffe project in `Release` mode:
```
PS > .\build.ps1 -Release
```

Build the Giraffe project in `Debug` mode and also build and run the tests project:
```
PS > .\build.ps1 -IncludeTests
```

Same as before, but also build and test the samples project:
```
PS > .\build.ps1 -IncludeTests -IncludeSamples
```

One switch to build and test all projects:
```
PS > .\build.ps1 -All
```

Build and test all projects, use the `Release` build configuration and create all NuGet packages:
```
PS > .\build.ps1 -Release -All -Pack
```

### Building on Linux or macOS

In order to successfully run the build script on Linux or macOS you will have to [install PowerShell for Linux or Mac](https://github.com/PowerShell/PowerShell#get-powershell).

Additionally you will have to [install the latest version of Mono](http://www.mono-project.com/download/) and execute the `./build.sh` script which will set the correct `FrameworkPathOverride` before subsequently executing the `./build.ps1` PowerShell script.

### Development environment

Currently the best way to work with F# on .NET Core is to use [Visual Studio Code](https://code.visualstudio.com/) with the [Ionide](http://ionide.io/) extension. Intellisense and debugging is supported with the latest versions of both.

## Contributing

Help and feedback is always welcome and pull requests get accepted.

### TL;DR

- First open an issue to discuss your changes
- After your change has been formally approved please submit your PR **against the develop branch**
- Please follow the code convention by examining existing code
- Add/modify the `README.md` as required
- Add/modify unit tests as required
- Please document your changes in the upcoming release notes in `RELEASE_NOTES.md`
- PRs can only be approved and merged when all checks succeed (builds on Windows and Linux)

### Discuss your change first

When contributing to this repository, please first discuss the change you wish to make via an [open issue](https://github.com/giraffe-fsharp/Giraffe/issues/new) before submitting a pull request. For new feature requests please describe your idea in more detail and how it could benefit other users as well.

Please be aware that Giraffe strictly aims to remain as light as possible while providing generic functionality for building functional web applications. New feature work must be applicable to a broader user base and if this requirement cannot be sufficiently met then a pull request might get rejected. In the case of doubt the maintainer might rather reject a potentially useful feature than adding one too many. This measure is to protect the repository from feature bloat and shall not be taken personally.

### Code conventions

When making changes please use existing code as a guideline for coding style and documentation. For example add spaces when creating tuples (`(a,b)` --> `(a, b)`), annotating variable types (`str:string` --> `str : string`) or other language constructs.

Examples:

```fsharp
let someHttpHandler:HttpHandler =
    fun (ctx:HttpContext) next -> task {
        // Some work
    }
```

should be:

```fsharp
let someHttpHandler : HttpHandler =
    fun (ctx : HttpContext) (next : HttpFunc) ->
        task {
            // Some work
        }
```

### Keep documentation and unit tests up to date

If you intend to add or change an existing `HttpHandler` then please update the `README.md` file to reflect these changes there as well. If applicable unit tests must be added or updated and the project must successfully build before a pull request can be accepted.

### Submit a pull request against develop

The `develop` branch is the main and only branch which should be used for all pull requests. A merge into `develop` means that your changes are scheduled to go live with the very next release, which could happen any time from the same day up to a couple weeks (depending on priorities and urgency).

Only pull requests which pass all build checks and comply with the general coding guidelines can be approved.

If you have any further questions please let me know.

You can file an [issue on GitHub](https://github.com/giraffe-fsharp/Giraffe/issues/new) or contact me via [https://dusted.codes/about](https://dusted.codes/about).

## Nightly builds and NuGet feed

All official Giraffe packages are published to the official and public NuGet feed.

Unofficial builds (such as pre-release builds from the `develop` branch and pull requests) produce unofficial pre-release NuGet packages which can be pulled from the project's public NuGet feed on AppVeyor:

```
https://ci.appveyor.com/nuget/giraffe
```

If you add this source to your NuGet CLI or project settings then you can pull unofficial NuGet packages for quick feature testing or urgent hot fixes.

**Please be aware that unofficial builds have not gone through the scrunity of offical releases and their usage is on your own risk.**

## Blog posts

- [Functional ASP.NET Core](https://dusted.codes/functional-aspnet-core) (by Dustin M. Gorski)
- [Functional ASP.NET Core part 2 - Hello world from Giraffe](https://dusted.codes/functional-aspnet-core-part-2-hello-world-from-giraffe) (by Dustin M. Gorski)
- [Carry On! … Continuation over binding pipelines for functional web](https://medium.com/@gerardtoconnor/carry-on-continuation-over-binding-pipelines-for-functional-web-58bd7e6ea009) (by Gerard)
- [A Functional Web with ASP.NET Core and F#'s Giraffe](https://www.hanselman.com/blog/AFunctionalWebWithASPNETCoreAndFsGiraffe.aspx) (by Scott Hanselman)
- [Build a web service with F# and .NET Core 2.0](https://blogs.msdn.microsoft.com/dotnet/2017/09/26/build-a-web-service-with-f-and-net-core-2-0/) (by Phillip Carter)
- [Giraffe brings F# functional programming to ASP.Net Core](https://www.infoworld.com/article/3229005/web-development/f-and-functional-programming-come-to-asp-net-core.html) (by Paul Krill from InfoWorld)

If you have blogged about Giraffe, demonstrating a useful topic or some other tips or tricks then please feel free to submit a pull request and add your article to this list as a reference for other Giraffe users. Thank you!

## Videos

- [Getting Started with ASP.NET Core Giraffe](https://www.youtube.com/watch?v=HyRzsPZ0f0k&t=461s) (by Ody Mbegbu)
- [Nikeza - Building the Backend with F#](https://www.youtube.com/watch?v=lANg1kn835s) (by Let's Code .NET)

## License

[Apache 2.0](https://raw.githubusercontent.com/giraffe-fsharp/Giraffe/master/LICENSE)

## Contact and Slack Channel

If you have any further questions feel free to reach out to me via any of the mentioned social media on [https://dusted.codes/about](https://dusted.codes/about) or join the `#giraffe` Slack channel in the [Functional Programming Slack Team](https://functionalprogramming.slack.com/). Please use [this link](https://fpchat-invite.herokuapp.com/) to request an invitation to the Functional Programming Slack Team.
