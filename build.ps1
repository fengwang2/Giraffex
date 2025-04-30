# ----------------------------------------------
# Build script
# ----------------------------------------------

param
(
    [switch] $Release,
    [switch] $ExcludeTests,
    [switch] $ExcludeSamples,
    [switch] $Pack,
    [switch] $Run,
    [switch] $OnlyNetStandard,
    [switch] $ClearOnly
)

$ErrorActionPreference = "Stop"

# ----------------------------------------------
# Helper functions
# ----------------------------------------------

function Test-IsWindows
{
    [environment]::OSVersion.Platform -ne "Unix"
}

function Invoke-Cmd ($cmd)
{
    Write-Host $cmd -ForegroundColor DarkCyan
    if (Test-IsWindows) { $cmd = "cmd.exe /C $cmd" }
    Invoke-Expression -Command $cmd
    if ($LastExitCode -ne 0) { Write-Error "An error occured when executing '$cmd'."; return }
}

function dotnet-info                      { Invoke-Cmd "dotnet --info" }
function dotnet-version                   { Invoke-Cmd "dotnet --version" }
function dotnet-run     ($project, $argv) { Invoke-Cmd "dotnet run --project $project $argv" }
function dotnet-test    ($project, $argv) { Invoke-Cmd "dotnet test $project $argv" }
function dotnet-pack    ($project, $argv) { Invoke-Cmd "dotnet pack $project $argv" }

function Get-DotNetRuntimeVersion
{
    $info = dotnet-info
    [System.Array]::Reverse($info)
    $version = $info | Where-Object { $_.Contains("Version")  } | Select-Object -First 1
    $version.Split(":")[1].Trim()
}

function Get-TargetFrameworks ($projFile)
{
    [xml]$proj = Get-Content $projFile

    if ($proj.Project.PropertyGroup.TargetFrameworks -ne $null) {
        ($proj.Project.PropertyGroup.TargetFrameworks).Split(";")
    }
    else {
        @($proj.Project.PropertyGroup.TargetFramework)
    }
}

function Get-NetCoreTargetFramework ($projFile)
{
    Get-TargetFrameworks $projFile | where { $_ -like "netstandard*" -or $_ -like "netcoreapp*" }
}

function dotnet-build ($project, $argv)
{
    if ($OnlyNetStandard.IsPresent) {
        $fw = Get-NetCoreTargetFramework $project
        $argv += " -f $fw"
    }

    Invoke-Cmd "dotnet build $project $argv"
}

function dotnet-xunit ($project, $argv)
{
    if(!(Test-IsWindows) -or $OnlyNetStandard.IsPresent) {
        $tfw = Get-NetCoreTargetFramework $project;
        $argv += " -framework $tfw"
    }

    $fxversion = Get-DotNetRuntimeVersion
    Push-Location (Get-Item $project).Directory.FullName
    Invoke-Cmd "dotnet xunit -fxversion $fxversion $argv"
    Pop-Location
}

function Write-DotnetVersion
{
    $dotnetSdkVersion = dotnet-version
    Write-Host ".NET Core SDK version:      $dotnetSdkVersion" -ForegroundColor Cyan
}

function Write-DotnetInfo
{
    $dotnetRuntimeVersion = Get-DotNetRuntimeVersion
    Write-Host ".NET Core Runtime version:  $dotnetRuntimeVersion" -ForegroundColor Cyan
}

function Test-Version ($project)
{
    if ($env:APPVEYOR_REPO_TAG -eq $true)
    {
        Write-Host "Matching version against git tag..." -ForegroundColor Magenta

        [xml] $xml = Get-Content $project
        [string] $version = $xml.Project.PropertyGroup.Version
        [string] $gitTag  = $env:APPVEYOR_REPO_TAG_NAME

        Write-Host "Project version: $version" -ForegroundColor Cyan
        Write-Host "Git tag version: $gitTag" -ForegroundColor Cyan

        if (!$gitTag.EndsWith($version))
        {
            Write-Error "Version and Git tag do not match."
        }
    }
}

function Update-AppVeyorBuildVersion ($project)
{
    if ($env:APPVEYOR -eq $true)
    {
        Write-Host "Updating AppVeyor build version..." -ForegroundColor Magenta

        [xml]$xml = Get-Content $project
        $version = $xml.Project.PropertyGroup.Version
        $buildVersion = "$version-$env:APPVEYOR_BUILD_NUMBER"
        Write-Host "Setting AppVeyor build version to $buildVersion."
        Update-AppveyorBuild -Version $buildVersion
    }
}

function Remove-OldBuildArtifacts
{
    Write-Host "Deleting old build artifacts..." -ForegroundColor Magenta

    Get-ChildItem -Include "bin", "obj" -Recurse -Directory `
    | ForEach-Object {
        Write-Host "Removing folder $_" -ForegroundColor DarkGray
        Remove-Item $_ -Recurse -Force }
}

# ----------------------------------------------
# Main
# ----------------------------------------------

if ($ClearOnly.IsPresent) {
    Remove-OldBuildArtifacts
    return
}

$giraffe               = ".\src\Giraffe\Giraffe.fsproj"
$giraffeTests          = ".\tests\Giraffe.Tests\Giraffe.Tests.fsproj"
$giraffeAcceptTests    = ".\tests\Giraffe.AcceptanceTests\Giraffe.AcceptanceTests.fsproj"
$identityApp           = ".\samples\IdentityApp\IdentityApp\IdentityApp.fsproj"
$jwtApp                = ".\samples\JwtApp\JwtApp\JwtApp.fsproj"
$sampleApp             = ".\samples\SampleApp\SampleApp\SampleApp.fsproj"
$sampleAppTests        = ".\samples\SampleApp\SampleApp.Tests\SampleApp.Tests.fsproj"

Update-AppVeyorBuildVersion $giraffe
Test-Version $giraffe
Write-DotnetVersion
Write-DotnetInfo
Remove-OldBuildArtifacts

$configuration = if ($Release.IsPresent) { "Release" } else { "Debug" }

Write-Host "Building Giraffe..." -ForegroundColor Magenta
dotnet-build   $giraffe "-c $configuration"

if (!$ExcludeTests.IsPresent -and !$Run.IsPresent)
{
    Write-Host "Building and running tests..." -ForegroundColor Magenta

    dotnet-build $giraffeTests
    dotnet-xunit $giraffeTests

    dotnet-build $giraffeAcceptTests
    # dotnet-xunit $giraffeAcceptTests

}

if (!$ExcludeSamples.IsPresent -and !$Run.IsPresent)
{
    Write-Host "Building and testing samples..." -ForegroundColor Magenta

    dotnet-build   $identityApp
    dotnet-build   $jwtApp
    dotnet-build   $sampleApp

    dotnet-build   $sampleAppTests
    dotnet-xunit   $sampleAppTests
}

if ($Run.IsPresent)
{
    Write-Host "Launching sample application..." -ForegroundColor Magenta
    dotnet-build   $sampleApp
    dotnet-run     $sampleApp
}

if ($Pack.IsPresent)
{
    Write-Host "Packaging Giraffe NuGet package..." -ForegroundColor Magenta

    dotnet-pack $giraffe "-c $configuration"
}