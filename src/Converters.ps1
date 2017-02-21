########################################################
##
## Converters.ps1
## Pip.Tasks - Cross platform project build system
## Data conversion functions
##
#######################################################

function ConvertTo-Hashtable 
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory=$False, Position = 0, ValueFromPipeline=$True)]
        [Object] $InputObject = $null
    )
    process 
    {
        if ($null -eq $InputObject) { return @{} }

        if ($InputObject -is [Hashtable]) 
        {
            $InputObject
        } 
        elseif ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) 
        {
            $collection = 
            @(
                foreach ($object in $InputObject) { ConvertTo-Hashtable $object }
            )

            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject]) 
        {
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties) 
            {
                $hash[$property.Name] = ConvertTo-Hashtable $property.Value
            }

            $hash
        }
        else 
        {
            $InputObject
        }
    }
}

function ConvertFrom-Hashtable 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelinebyPropertyName=$true)]
        [hashtable] $InputObject
    )
    process
    { 
        $result = New-Object PSObject

        foreach ($key in $InputObject.keys) 
        {
            $result | Add-Member -MemberType NoteProperty -Name $key -Value $InputObject[$key]
        }

        $result
    }
}

function ConvertFrom-Xml
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelinebyPropertyName=$true)]
        [xml] $InputObject
    )
    process
    {
        $sw = [System.IO.StringWriter]::new()
        $xmlSettings = [System.Xml.XmlWriterSettings]::new()
        $xmlSettings.ConformanceLevel = [System.Xml.ConformanceLevel]::Fragment
        $xmlSettings.Indent = $true
        $xw = [System.Xml.XmlWriter]::Create($sw, $xmlSettings)
        $InputObject.WriteTo($xw)
        $xw.Close()
        return $sw.ToString()
    }
}