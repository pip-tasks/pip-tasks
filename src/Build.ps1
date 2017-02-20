########################################################
##
## Build.ps1
## Pip.Tasks - Cross platform project build system
## Global build commands
##
#######################################################


function Invoke-Task
{
<#
.SYNOPSIS

Invokes build task across workspace component

.DESCRIPTION

Invokes build for specific components in selected workspace

.PARAMETER Path

Path somewhere within component (default: .)

.PARAMETER Component

Component or list of components (default: current component)

.PARAMETER All

Executes task for all components in the workspace

.PARAMETER Workspace

Executes workspace task

.PARAMETER Task

A task or list of tasks to execute (default: default)

.PARAMETER Parameters

A set of build parameters

.PARAMETER Properties

A set of build properties (executed after parameters)

.PARAMETER Force

Forces continue after failure of component tasks

.PARAMETER Parallel

Attempts to execute component tasks in parallel

.EXAMPLE

PS> Invoke-Task -Component Component1, Component2 -Path . -Task Clear, Compile -Parameters @{ Configuration="Release" }

#>
    # [CmdletBinding()]
    param
    (
        # [Parameter(Mandatory=$false, Position=0)]
        [string[]]$Task = @(),
        # [Parameter(Mandatory=$false)]
        [string] $Path = '.',
        # [Parameter(Mandatory=$false)]
        [string[]]$Component = @(),
        # [Parameter(Mandatory=$false)]
        [hashtable]$Parameters = @{},
        # [Parameter(Mandatory=$false)]
        [hashtable]$Properties = @{},
        # [Parameter(Mandatory=$false)]
        [switch] $All,
        # [Parameter(Mandatory=$false)]
        [switch] $Workspace,
        # [Parameter(Mandatory=$false)]
        [switch] $Global,
        # [Parameter(Mandatory=$false)]
        [switch] $Force,
        # [Parameter(Mandatory=$false)]
        [switch] $Parallel
    )
    begin {}
    process 
    {
        $ws = Find-Workspace -Path $Path
        if ($ws -eq $null) { throw "Workspace at $Path was not found" }

        $Task = Convert-ArgsToArray -Arguments $Args -Include $Task
        $Properties = Convert-ArgsToHashmap -Arguments $Args -Include $Properties

        if ($Global) { $All = $Workspace = $true }

        # Lookup all components
        if ($All) { $Component = Get-Components -Path $Path }

        # Process when no components defined
        if ($Component.Count -eq 0 -and -not $Workspace)
        {
            # Set current component
            $c = Find-Component -Path $Path
            if ($c -ne $null)
            {
                $Component += $(Get-Item -Path $c).Name
            }
            # Or execute task for the current workspace
            else
            {
                $Workspace = $true
            }
        }

        # Execute task for the current workspace and exit
        if ($Workspace) 
        {
            if ($Force)
            {
                Invoke-WorkspaceTask -Path $ws -Task $Task -Parameters $Parameters -Properties $Properties -Force
            }
            else 
            {
                Invoke-WorkspaceTask -Path $ws -Task $Task -Parameters $Parameters -Properties $Properties
            }
        }

        # Execute task for all specified components
        foreach ($c in $Component)
        {
            $cp = "$ws/$c"

            if ($Force)
            {
                Invoke-ComponentTask -Path $cp -Task $Task -Parameters $Parameters -Properties $Properties -Force
            }
            else 
            {
                Invoke-ComponentTask -Path $cp -Task $Task -Parameters $Parameters -Properties $Properties
            }
        }
    }
    end {}
}

