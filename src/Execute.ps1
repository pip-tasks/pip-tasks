########################################################
##
## Execute.ps1
## Pip.Tasks - Cross platform project build system
## Execution functions
##
#######################################################

function Invoke-At
{
<#
.SYNOPSIS

Invokes script block in specified location

.DESCRIPTION

Invoke-At checks and set specified location, executes script block and then restores the previous location

.PARAMETER Path

Path where to execute the script block

.PARAMETER Block

Script block to be executed

.EXAMPLE

PS> Invoke-At -Path /bin -Block { Write-Output "Current location is: $(Get-Location)" }

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Path,

        [Parameter(Mandatory=$true, Position=1)]
        [scriptblock] $Block
    )
    begin {}
    process 
    {
        if (-not (Test-Path -Path $Path)) { throw "Path $Path does not exist" }

        $_sl = Get-Location
        Set-Location -Path $Path

        try
        {
            . $Block
        }
        finally
        {
            Set-Location -Path $_sl
        }
    }
    end {}
}


function Invoke-External
{
<#
.SYNOPSIS

Invokes external command

.DESCRIPTION

Invoke-External executes external command, checks LASTEXITCODE and throws an exception if invocation wasn't successful

.PARAMETER Command

External command be executed

.PARAMETER ErrorMessage

Error message to throw when invocation fails

.EXAMPLE

PS> Invoke-External { git status } "Git status failed"

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [scriptblock] $Command,

        [Parameter(Mandatory=$false, Position=1)]
        [string] $ErrorMessage = $null,

        [Parameter(Mandatory=$false, Position=2)]
        [switch] $CaptureOutput
    )
    begin {}
    process 
    {
        $Global:LASTEXITCODE = 0

        if ($CaptureOutput)
        {
            $output = & $Command
        }
        else
        {
            & $Command
        }
        
        if ($LASTEXITCODE -ne 0) 
        { 
            if ($output -ne $null -and $Output -ne '') { throw $output } 
            elseif ($ErrorMessage -ne $null -and $ErrorMessage -ne '') { throw $ErrorMessage }
            else { throw "Execution failed with error code $LASTEXITCODE" }
        }

        Write-Output $Output
    }
    end {}
}
