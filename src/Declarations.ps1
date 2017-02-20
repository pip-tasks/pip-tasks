########################################################
##
## Declarations.ps1
## Pip.Tasks - Cross platform project build system
## Configuration for declarative tasks
##
#######################################################

$Script:PipDeclarativeTasks = @{}

function Get-DeclarativeTaskNames
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
        $names = @()
        foreach ($task in $PipDeclarativeTasks.Keys)
        {
            $declarations = $PipDeclarativeTasks[$task]
            $found = $false
            foreach ($declaration in $declarations)
            {
                if ($Workspace -and $declaration.Workspace) { $found = $true }
                if ($Component -and $declaration.Component) { $found = $true }
            }
            if ($found)
            {
                $names += $task
            }
        }
        return $names
    }
    end {}
}

function Find-DeclarativeTask
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Task,
        [Parameter(Mandatory=$false)]
        [switch] $Workspace,
        [Parameter(Mandatory=$false)]
        [switch] $Component
    )
    begin {}
    process 
    {        
        $declarations = $PipDeclarativeTasks[$Task]
        if ($declarations -eq $null -or $declarations.Count -eq 0) 
        { 
            return "Task $Task was not declared" 
        }

        $variable = $declarations[0].Variable
        $value = Get-Variable -Name $variable -ValueOnly -ErrorAction Ignore

        if ($value -eq $null) { throw "$variable is not set" }
        if ($value -eq 'none') { return $null }

        foreach ($declaration in $declarations)
        {
            if ($Workspace -and -not $declaration.Workspace) { continue }
            if ($Component -and -not $declaration.Component) { continue }
            if ($declaration.Value -ne $value) { continue }

            return $declaration
        }

        throw "$Task for $value is not supported"
    }
    end {}
}


function Register-DeclarativeTask
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Task,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $Variable,
        [Parameter(Mandatory=$true, Position=2)]
        [string] $Value,
        [Parameter(Mandatory=$true, Position=3)]
        [string] $CallFile,
        [Parameter(Mandatory=$true, Position=4)]
        [string] $CallTask,
        [Parameter(Mandatory=$false)]
        [switch] $Workspace,
        [Parameter(Mandatory=$false)]
        [switch] $Component
    )
    begin {}
    process 
    {        
        # Get task declarations
        $declarations = $PipDeclarativeTasks[$Task]
        if ($declarations -eq $null) { $declarations = @() }

        # Do not allow different variables for the same task
        $oldVariable = $Variable
        if ($declarations.Count -ne 0) 
        {
            $oldVariable = $declarations[0].Variable
        }
        if ($oldVariable -ne $Variable) 
        { 
            throw "Task $Task already uses $oldVariable" 
        }

        # Add the new declaration
        $declarations += @{
            Variable = $Variable;
            Value = $Value;
            File = $CallFile;
            Task = $CallTask;
            Workspace = $Workspace;
            Component = $Component;
        }

        $Script:PipDeclarativeTasks[$Task] = $declarations; 
    }
    end {}
}


function Unregister-DeclarativeTask
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $Task,
        [Parameter(Mandatory=$false, Position=1)]
        [string] $Variable,
        [Parameter(Mandatory=$false, Position=2)]
        [string] $Value,
        [Parameter(Mandatory=$false)]
        [switch] $All
    )
    begin {}
    process 
    {        
        if ($All)
        {  
            $PipDeclarativeTasks.Remove($Task); 
        }
        else 
        {
            $oldDeclarations = $PipDeclarativeTasks[$Task]
            if ($oldDeclarations -eq $null) { return }

            $declarations = @()
            foreach ($declaration in $declarations) 
            { 
                if ($Variable -ne $declaration.Variable -or $Value -ne $declaration.Value)
                {
                    $declarations += $declaration
                }
            }            

            $Script:PipDeclarativeTasks[$Task] = $declarations; 
        }
    }
    end {}
}


function Get-DeclarativeTasks
{
    [CmdletBinding()]
    param ()
    begin {}
    process 
    {        
        foreach ($task in $PipDeclarativeTasks.Keys)
        {
            $declarations = $PipDeclarativeTasks[$task]
            if ($declarations -eq $null -or $declarations.Count -eq 0) { continue }

            $variable = $null
            $values = @()

            foreach ($declaration in $declarations)
            {
                $variable = $declaration.Variable
                $values += $declaration.Value
            }

            # $props = @{ 
            #     Task=$task; 
            #     Variable=$variable; 
            #     Values=$values;
            # }
            # $obj = New-Object –TypeName PSObject -Prop $props
            # Write-Output $props

            Write-Output $task
        }
    }
    end {}
}