########################################################
##
## Workspace.ps1
## Pip.Tasks - Cross platform project build system
## Workspace build commands
##
#######################################################


function Test-Workspace
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $Path = $null
    )
    begin {}
    process 
    {
        if ($Path -eq $null) { return $false }

        if (Test-Path -Path "$Path/environment.ps1") { return $true }

        if (Test-Path -Path "$Path/global.conf.ps1") { return $true }
        if (Test-Path -Path "$Path/global.conf.override.ps1") { return $true }
        if (Test-Path -Path "$Path/global.build.ps1") { return $true }
        if (Test-Path -Path "$Path/global.build.override.ps1") { return $true }

        if (Test-Path -Path "$Path/workspace.conf.ps1") { return $true }
        if (Test-Path -Path "$Path/workspace.build.ps1") { return $true }

        return $false
    }
    end {}
}


function Find-Workspace
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $Path = '.'
    )
    begin {}
    process 
    {
        if (Test-Workspace -Path $Path) 
        { 
            return (Get-Item -Path $Path).FullName 
        }

        $item = Get-Item -Path $Path -ErrorAction SilentlyContinue
        if ($item.Parent -ne $null)
        { 
            return Find-Workspace -Path $item.Parent.FullName
        }

        return $DefaultWorkspace
    }
    end {}
}


function Invoke-WorkspaceTask
{
<#
.SYNOPSIS

Invokes build task for workspace

.DESCRIPTION

Invokes build for workspace

.PARAMETER Path

Path somewhere within workspace (default: $Workspace)

.PARAMETER Task

A task or list of tasks to execute (default: default)

.PARAMETER Parameters

A set of build parameters

.PARAMETER Properties

A set of build properties (executed after parameters)

.PARAMETER Framework

.NET Framework version

.EXAMPLE

PS> Invoke-WorkspaceTask -Path . -Task Init -Parameters @{ Branch="Master" }

#>
    # [CmdletBinding()]
    param
    (
        # [Parameter(Mandatory=$false, Position=0)]
        [string[]]$Task = @(),
        # [Parameter(Mandatory=$false)]
        [string] $Path = '.',
        # [Parameter(Mandatory=$false)]
        [hashtable]$Parameters = @{},
        # [Parameter(Mandatory=$false)]
        [hashtable]$Properties = @{},
        # [Parameter(Mandatory=$false)]
        [switch] $Force
    )
    begin {}
    process 
    {
        $Task = Convert-ArgsToArray -Arguments $Args -Include $Task
        $Properties = Convert-ArgsToHashmap -Include $Properties -Arguments $Args 

        $f1 = "$PSScriptRoot/../lib/Invoke-Build/Invoke-Build.ps1"
        if (-not (Test-Path -Path $f1)) { throw "Internal error: Invoke-Build dependency was not found" }

        $f2 = "$PSScriptRoot/Workspace.build.ps1"
        if (-not (Test-Path -Path $f2)) { throw "Internal error: Workspace.build was not found" }

        $Path = Find-Workspace -Path $Path
        if ($Path -eq $null -or $Path -eq '') { throw "Workspace was not found" }
        $Path = $(Get-Item -Path $Path).FullName

        if ($Force)
        {
            & $f1 -Task $Task -File $f2 -Path $Path -Params $Parameters -Properties $Properties -Safe -Result Result
            if ($Result.Error) { Write-Warning "Build failed. Continue..." }
        }
        else 
        {
            & $f1 -Task $Task -File $f2 -Path $Path -Params $Parameters -Properties $Properties
        }
    }
    end {}
}


function Use-Workspace
{
<#
.SYNOPSIS

Selects workspace and loads its environment variables

.DESCRIPTION

Loads standard workspace dependencies, tasks and properties

.PARAMETER Path

Workspace path (default: .)

.EXAMPLE

# Remember to use "." (dot) notation!
PS> . Use-Workspace -Path C:/Projects/pip-tasks-org

#>
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $Path = '.'
    )
    begin {}
    process 
    {
        # Find workspace at specified path
        $global:DefaultWorkspace = Find-Workspace -Path $Path
        if ($DefaultWorkspace -eq $null -or $DefaultWorkspace -eq '') { throw "Workspace at $Path was not found" }

        # Load environment variables
        if (Test-Path "$DefaultWorkspace/environment.ps1")
        {
            . "$DefaultWorkspace/environment.ps1"
        }
    }
    end {}
}