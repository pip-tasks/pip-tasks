########################################################
##
## Properties.ps1
## Pip.Tasks - Cross platform project build system
## Properties processing functions
##
#######################################################


function Find-Properties
{
<#
.SYNOPSIS

Finds properties by key

.DESCRIPTION

Find-Properties finds properties by key in properties array

.PARAMETER Properties

Array of properties

.PARAMETER KeyName

Property key field names

.PARAMETER Key

Property key field value

.PARAMETER DefaultKey

Property default key field value

.EXAMPLE

PS> Find-Properties -Properties $props -Key 'local'

#>
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [array] $Properties = @(),
        [Parameter(Mandatory=$false, Position=1)]
        [string] $KeyName = 'Name',
        [Parameter(Mandatory=$true, Position=2)]
        [string] $Key,
        [Parameter(Mandatory=$false, Position=3)]
        [string] $DefaultKey = 'default'
    )
    begin {}
    process
    {
        if ($Key -eq $null -or $Key -eq '') { $Key = $DefaultKey }

        $result = @{}
        foreach ($p in $Properties) 
        {
            if ($p.$KeyName -eq $Key)
            {
                $result = $p
            }
        }

        Write-Output $result
    }
    end {}
}


function Set-Properties
{
<#
.SYNOPSIS

Sets property variables

.DESCRIPTION

Set-Properties sets variables based on properties key-value pairs

.PARAMETER Properties

Array of properties

.PARAMETER Prefix

Variable name prefix (default: '')

.PARAMETER Override

Overrides existing variable (default: $true)

.EXAMPLE

PS> Set-Properties -Properties $props -Prefix 'Deploy'

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [hashtable] $Properties,
        [Parameter(Mandatory=$false, Position=1)]
        [string] $Prefix = '',
        [Parameter(Mandatory=$false, Position=2)]
        [string] $Scope = 'Script',
        [Parameter(Mandatory=$false, Position=3)]
        [bool] $Override = $true
    )
    begin {}
    process
    {
        foreach ($key in $Properties.keys) 
        {
            $var = "$prefix$key"    
            if ($Override -or -not (Test-Path -Path "variable:/$var")) 
            {
                Set-Variable -Name $var -Value $Properties.$key -Scope $Scope | Out-Null
            }
        }
    }
    end {}
}
