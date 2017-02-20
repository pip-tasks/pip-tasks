########################################################
##
## Includes.ps1
## Pip.Tasks - Cross platform project build system
## Configuration for imperative build script includes
##
#######################################################

$Global:PipImperativeIncludes = @()

function Get-ImperativeIncludes
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false)]
        [switch] $Workspace,
        [Parameter(Mandatory=$false)]
        [switch] $Component
    )
    begin {}
    process 
    {        
        foreach ($include in $Global:PipImperativeIncludes)
        {
            if ($Workspace -and $include.Workspace)
            {
                Write-Output $include
            }
            elseif ($Component -and $include.Component)
            {
                Write-Output $include
            }
        }
    }
    end {}
}


function Register-ImperativeInclude
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $CallFile,
        [Parameter(Mandatory=$false)]
        [switch] $Workspace,
        [Parameter(Mandatory=$false)]
        [switch] $Component
    )
    begin {}
    process 
    {        
        Unregister-ImperativeInclude -CallFile $CallFile

        $Global:PipImperativeIncludes += @{
            File = $CallFile;
            Workspace = $Workspace;
            Component = $Component;
        }
    }
    end {}
}


function Unregister-ImperativeInclude
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $CallFile
    )
    begin {}
    process 
    {        
        $oldIncludes = $Global:PipImperativeIncludes
        $Global:PipImperativeIncludes = @()
        foreach ($include in $oldIncludes)
        {
            if ($include.File -ne $CallFile)
            {
                $Global:PipImperativeIncludes += $include
            }
        }
    }
    end {}
}
