########################################################
##
## Files.ps1
## Pip.Tasks - Cross platform project build system
## File and directory manipulation commands and functions
##
#######################################################

function New-SoftLink
{
<#
.SYNOPSIS

Creates a soft link to file or directory

.DESCRIPTION

New-SoftLink creates a soft link to file or directory

.PARAMETER SourcePath

Path to source file or directory

.PARAMETER DestPath

Path to destination file or directory

.EXAMPLE

PS> New-SoftLink -SourcePath ./dir -DestPath ./dir2

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $SourcePath,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $DestPath
    )
    begin {}
    process
    {
        if (Test-OS -Name 'Windows')
        {
            Invoke-External {
                & mklink /J $DestPath $SourcePath 2>&1 | Out-String
            } -CaptureOutput | Out-Null          
        }
        else
        {
            Invoke-External {
                & ln -s $SourcePath $DestPath 2>&1 | Out-String
            } -CaptureOutput | Out-Null         
        }
    }
    end {}
}
