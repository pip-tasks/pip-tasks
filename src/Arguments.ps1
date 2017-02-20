########################################################
##
## Arguments.ps1
## Pip.Tasks - Cross platform project build system
## Argument conversion functions
##
#######################################################

function Convert-ArgsToHashmap
{
<#
.SYNOPSIS

Converts list of arguments to hashmap

.DESCRIPTION

Convert-ArgsToHashmap converts list of arguments to hashmap and excludes from that reserved arguments

.PARAMETER Arguments

Array of unprocessed arguments

.PARAMETER Include

Hashtable of arguments to add

.PARAMETER Exclude

List of argument names to exclude

.EXAMPLE

PS> Convert-ArgsToHashmap -Arguments $args -Exclude argument1, argument2

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [array] $Arguments = @(),

        [Parameter(Mandatory=$false, Position=1)]
        [hashtable] $Include = @{},

        [Parameter(Mandatory=$false, Position=2)]
        [string[]] $Exclude = @()
    )
    begin {}
    process 
    {
        $result = @{}
        $key = $null
        $value = $null

        foreach ($a in $Arguments)
        {
            if ($a -is [string] -and ([string]$a).StartsWith('-'))
            {
                $key = ([string]$a).Substring(1)
                $value = $null
                $result[$key] = $value
            }
            elseif ($key -ne $null)
            {
                if ($value -eq $null)
                {
                    $value = $a
                }
                elseif ($value -is [array])
                {
                    $value += $a
                }
                else
                {
                    $value = @( $value, $a )
                }
                $result[$key] = $value
            }
            else
            {
                # Ignore value without key
            }            
        }

        foreach ($c in $Exclude)
        {
            $result.Remove($c)
        }

        foreach ($k in $Include.Keys)
        {
            $result[$k] = $Include[$k]
        }

        Write-Output $result
    }
    end {}
}


function Convert-ArgsToArray
{
<#
.SYNOPSIS

Converts list of arguments to array

.DESCRIPTION

Convert-ArgsToArray converts list of initial position arguments to array

.PARAMETER Arguments

Array of unprocessed arguments

.PARAMETER Include

List of values to include

.EXAMPLE

PS> Convert-ArgsToArray -Arguments $args -Include argument1

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [array] $Arguments = @(),

        [Parameter(Mandatory=$false, Position=1)]
        [array] $Include = @()
    )
    begin {}
    process 
    {
        $result = $Include

        foreach ($a in $Arguments)
        {
            if (-not ($a -is [string] -and ([string]$a).StartsWith('-')))
            {
                $result += $a
            }
            else 
            {
                break   
            }
        }

        Write-Output $result
    }
    end {}
}