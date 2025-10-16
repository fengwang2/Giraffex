# ----------------------------------------------
# Generic functions
# ----------------------------------------------

function Test-IsWindows
{
    <#
        .DESCRIPTION
        Checks to see whether the current environment is Windows or not.

        .EXAMPLE
        if (Test-IsWindows) { Write-Host "Hello Windows" }
    #>

    [environment]::OSVersion.Platform -ne "Unix"
}

function Invoke-Cmd ($Cmd)
{
    <#
        .DESCRIPTION
        Runs a shell or bash command and throws an error if the command didn't exit with 0.

        .PARAMETER cmd
        The command to be executed.

        .EXAMPLE
        Invoke-Cmd -Cmd "dotnet new classlib"

        .NOTES
        Use this PowerShell command to execute any dotnet CLI commands in order to ensure that they behave the same way in the case of an error across different environments (Windows, OSX and Linux).
    #>

    Write-Host $Cmd -ForegroundColor DarkCyan
    if (Test-IsWindows) { $Cmd = "cmd.exe /C $Cmd" }
    Invoke-Expression -Command $Cmd
    if ($LastExitCode -ne 0) { Write-Error "An error occured when executing '$Cmd'."; return }
}

function Remove-OldBuildArtifacts
{
    <#
        .DESCRIPTION
        Deletes all the bin and obj folders from the current- and all sub directories.
    #>

    Write-Host "Deleting old build artifacts..." -ForegroundColor Magenta

    Get-ChildItem -Include "bin", "obj" -Recurse -Directory `
    | ForEach-Object {
        Write-Host "Removing folder $_" -ForegroundColor DarkGray
        Remove-Item $_ -Recurse -Force }
}

function Test-CompareVersions ($projFile, [string]$gitTag)
{
    Write-Host "Matching version against git tag..." -ForegroundColor Magenta

    [xml]$xml = Get-Content $projFile
    [string]$version = $xml.Project.PropertyGroup.Version

    Write-Host "Project version: $version" -ForegroundColor Cyan
    Write-Host "Git tag version: $gitTag" -ForegroundColor Cyan

    if (!$gitTag.EndsWith($version))
    {
        Write-Error "Version and Git tag do not match."
    }
}

# ----------------------------------------------
# .NET Core functions
# ----------------------------------------------

function dotnet-info                      { Invoke-Cmd "dotnet --info" }
function dotnet-version                   { Invoke-Cmd "dotnet --version" }
function dotnet-build   ($project, $argv) { Invoke-Cmd "dotnet build $project $argv" }
function dotnet-run     ($project, $argv) { Invoke-Cmd "dotnet run --project $project $argv" }
function dotnet-pack    ($project, $argv) { Invoke-Cmd "dotnet pack $project $argv" }
function dotnet-publish ($project, $argv) { Invoke-Cmd "dotnet publish $project $argv" }

function Get-DotNetRuntimeVersion
{
    <#
        .DESCRIPTION
        Runs the dotnet --info command and extracts the .NET Core Runtime version number.

        .NOTES
        The .NET Core Runtime version can sometimes be useful for other dotnet CLI commands (e.g. dotnet xunit -fxversion ".NET Core Runtime version").
    #>

    $info = dotnet-info
    [System.Array]::Reverse($info)
    $version = $info | Where-Object { $_.Contains("Version")  } | Select-Object -First 1
    $version.Split(":")[1].Trim()
}

function Get-TargetFrameworks ($projFile)
{
    <#
        .DESCRIPTION
        Returns all target frameworks set up inside a specific .NET Core project file.

        .PARAMETER projFile
        The full or relative path to a .NET Core project file (*.csproj, *.fsproj, *.vbproj).

        .EXAMPLE
        Get-TargetFrameworks "MyProject.csproj"

        .NOTES
        This function will always return an array of target frameworks, even if only a single target framework was found in the project file.
    #>

    [xml]$proj = Get-Content $projFile

    if ($null -ne $proj.Project.PropertyGroup.TargetFrameworks) {
        ($proj.Project.PropertyGroup.TargetFrameworks).Split(";")
    }
    else { @($proj.Project.PropertyGroup.TargetFramework) }
}

function Get-NetCoreTargetFramework ($projFile)
{
    <#
        .DESCRIPTION
        Returns a single .NET Core framework which could be found among all configured target frameworks of a given .NET Core project file.

        .PARAMETER projFile
        The full or relative path to a .NET Core project file (*.csproj, *.fsproj, *.vbproj).

        .EXAMPLE
        Get-NetCoreTargetFramework "MyProject.csproj"

        .NOTES
        This function will always return the only netstandard*/netcoreapp* target framework which is set up as a target framework.
    #>

    Get-TargetFrameworks $projFile | Where-Object { $_ -like "netstandard*" -or $_ -like "netcoreapp*" }
}

function dotnet-test ($project, $argv)
{
    # Currently dotnet test does not work for net461 on Linux/Mac
    # See: https://github.com/Microsoft/vstest/issues/1318
    #
    # Previously dotnet-xunit was a working alternative, however
    # after issues with the maintenance of dotnet xunit it has been
    # discontinued since xunit 2.4: https://xunit.github.io/releases/2.4
    if(!(Test-IsWindows))
    {
        $fw = Get-NetCoreTargetFramework $project;
        $argv = "-f $fw " + $argv
    }
    Invoke-Cmd "dotnet test $project $argv"
}

function Write-DotnetCoreVersions
{
    <#
        .DESCRIPTION
        Writes the .NET Core SDK and Runtime version to the current host.
    #>

    $sdkVersion     = dotnet-version
    $runtimeVersion = Get-DotNetRuntimeVersion
    Write-Host ".NET Core SDK version:      $sdkVersion" -ForegroundColor Cyan
    Write-Host ".NET Core Runtime version:  $runtimeVersion" -ForegroundColor Cyan
}

function Get-DesiredSdk
{
    <#
        .DESCRIPTION
        Gets the desired .NET Core SDK version from the global.json file.
    #>

    Get-Content "global.json" `
    | ConvertFrom-Json `
    | ForEach-Object { $_.sdk.version.ToString() }
}

function Get-NetCoreSdkFromWeb ($version)
{
    <#
        .DESCRIPTION
        Downloads the desired .NET Core SDK version from the internet and saves it under a temporary file name which will be returned by the function.

        .PARAMETER version
        The SDK version which should be downloaded.
    #>

    $os = if (Test-IsWindows) { "windows" } else { "linux" }

    $response = Invoke-WebRequest `
                    -Uri "https://www.microsoft.com/net/download/thank-you/dotnet-sdk-$version-$os-x64-binaries" `
                    -Method Get `
                    -MaximumRedirection 0 `

    $downloadLink =
        $response.Links `
            | Where-Object { $_.onclick -eq "recordManualDownload()" } `
            | Select-Object -Expand href

    $tempFile  = [System.IO.Path]::GetTempFileName()
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($downloadLink, $tempFile)
    return $tempFile
}

function Install-NetCoreSdk ($sdkZipPath)
{
    <#
        .DESCRIPTION
        Extracts the zip archive which contains the .NET Core SDK and installs it in the current working directory under .dotnetsdk.

        .PARAMETER version
        The zip archive which contains the .NET Core SDK.
    #>


    $env:DOTNET_INSTALL_DIR = "$pwd\.dotnetsdk"
    New-Item $env:DOTNET_INSTALL_DIR -ItemType Directory -Force

    Add-Type -AssemblyName System.IO.Compression.FileSystem;
    [System.IO.Compression.ZipFile]::ExtractToDirectory($sdkZipPath, $env:DOTNET_INSTALL_DIR)
    $env:Path = "$env:DOTNET_INSTALL_DIR;$env:Path"
}

# ----------------------------------------------
# AppVeyor functions
# ----------------------------------------------

function Test-IsAppVeyorBuild                  { return ($env:APPVEYOR -eq $true) }
function Test-IsAppVeyorBuildTriggeredByGitTag { return ($env:APPVEYOR_REPO_TAG -eq $true) }
function Get-AppVeyorGitTag                    { return $env:APPVEYOR_REPO_TAG_NAME }

function Update-AppVeyorBuildVersion ($projFile)
{
    if (Test-IsAppVeyorBuild)
    {
        Write-Host "Updating AppVeyor build version..." -ForegroundColor Magenta

        [xml]$xml     = Get-Content $projFile
        $version      = $xml.Project.PropertyGroup.Version
        $buildVersion = "$version-$env:APPVEYOR_BUILD_NUMBER"
        Write-Host "Setting AppVeyor build version to $buildVersion."
        Update-AppveyorBuild -Version $buildVersion
    }
}