########################################################
##
## Component.ps1
## Pip.Tasks - Cross platform project build system
## Component build commands
##
#######################################################


function Test-Component
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

        if (Test-Path -Path "$Path/component.conf.ps1") { return $true }
        if (Test-Path -Path "$Path/component.build.ps1") { return $true }

        return $false
    }
    end {}
}


function Find-Component
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
        if (Test-Component -Path $Path) 
        { 
            return (Get-Item -Path $Path).FullName 
        }

        $item = Get-Item -Path $Path
        if ($item.Parent -ne $null)
        { 
            return Find-Component -Path $item.Parent.FullName
        }

        return $null
    }
    end {}
}


function Get-Components
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
        $ws = Find-Workspace -Path $Path
        if ($ws -eq $null) { return $null }

        foreach ($fld in $(Get-ChildItem -Path $ws -Directory))
        {
            if (Test-Component -Path $fld.FullName)
            {
                Write-Output $fld.Name
            }
        }
    }
    end {}
}


function Invoke-ComponentTask
{
<#
.SYNOPSIS

Invokes build task for specific component

.DESCRIPTION

Invokes build for specific component

.PARAMETER Path

Path somewhere within component (default: .)

.PARAMETER Task

A task or list of tasks to execute (default: default)

.PARAMETER Properties

A set of build properties (executed after parameters)

.EXAMPLE

PS> Invoke-ComponentTask -Path . -Task Clear, Compile -Parameters @{ Configuration="Release" }

#>
    # [CmdletBinding()]
    param
    (
        # [Parameter(Mandatory=$false, Position=0)]
        [string[]] $Task = @(),
        # [Parameter(Mandatory=$false)]
        [string] $Path = '.',
        # [Parameter(Mandatory=$false)]
        [hashtable] $Parameters = @{},
        # [Parameter(Mandatory=$false)]
        [hashtable] $Properties = @{},
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

        $f2 = "$PSScriptRoot/Component.build.ps1"
        if (-not (Test-Path -Path $f2)) { throw "Internal error: Component.build was not found" }

        $Path = Find-Component -Path $Path
        if ($Path -eq $null -or $Path -eq '') { throw "Component was not found" }
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
