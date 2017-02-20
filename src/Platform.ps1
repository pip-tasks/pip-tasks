########################################################
##
## Platform.ps1
## Pip.Tasks - Cross platform project build system
## Platform abstractions
##
#######################################################

function Get-OS
{
<#
.SYNOPSIS

Gets Operating System name

.DESCRIPTION

Get-OS returns the name of operating system: Windows, Linux, MacOS or Unknown

.EXAMPLE

PS> Get-OS

#>
    begin {}
    process
    {
        try 
        {
            $os = & sw_vers -productName
            if ($os -eq 'Mac OS X')
            {
                return 'MacOS'
            }
        }
        catch { }

        try 
        {
            $os = & uname
            if ($os -eq 'Linux')
            {
                return 'Linux'
            }
        }
        catch { }

        try 
        {
            $os = Get-WmiObject -Class Win32_operatingSystem
            if ($os -ne $null -and $os.Caption.Contains('Windows'))
            {
                return 'Windows'
            }
        }
        catch { }

        return 'Unknown'
    }
    end {}
}

function Test-OS
{
<#
.SYNOPSIS

Tests for specific Operating System

.DESCRIPTION

Test-OS compares actual OS with requested one

.PARAMETER Name

Name(s) of operating system

.EXAMPLE

PS> Test-OS -Name 'MacOS', 'Linux'

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string[]] $Name
    )
    begin {}
    process
    {
        $os = Get-OS
        foreach ($n in $Name) 
        {
            if ($n -eq $os) { return $true }
        }
        return $false
    }
    end {}
}
