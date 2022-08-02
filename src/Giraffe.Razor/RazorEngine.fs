module Giraffe.RazorEngine

open System
open System.IO
open Microsoft.AspNetCore.Http
open Microsoft.AspNetCore.Mvc
open Microsoft.AspNetCore.Mvc.Abstractions
open Microsoft.AspNetCore.Mvc.ModelBinding
open Microsoft.AspNetCore.Mvc.Razor
open Microsoft.AspNetCore.Mvc.Rendering
open Microsoft.AspNetCore.Mvc.ViewFeatures
open Microsoft.AspNetCore.Routing

let renderRazorView (razorViewEngine   : IRazorViewEngine)
                    (tempDataProvider  : ITempDataProvider)
                    (httpContext       : HttpContext)
                    (viewName          : string)
                    (model             : 'T) =
    async {
        let actionContext    = ActionContext(httpContext, RouteData(), ActionDescriptor())
        let viewEngineResult = razorViewEngine.FindView(actionContext, viewName, false)

        match viewEngineResult.Success with
        | false ->
            let locations = String.Join(" ", viewEngineResult.SearchedLocations)
            return Error (sprintf "Could not find view with the name '%s', looked in %s" viewName locations)
        | true  ->
            let view = viewEngineResult.View
            let viewDataDict       = ViewDataDictionary<'T>(EmptyModelMetadataProvider(), ModelStateDictionary(), Model = model)
            let tempDataDict       = TempDataDictionary(actionContext.HttpContext, tempDataProvider)
            let htmlHelperOptions  = HtmlHelperOptions()
            use output = new StringWriter()
            let viewContext = ViewContext(actionContext, view, viewDataDict, tempDataDict, output, htmlHelperOptions)
            do! view.RenderAsync(viewContext) |> Async.AwaitTask
            return Ok (output.ToString())
    }