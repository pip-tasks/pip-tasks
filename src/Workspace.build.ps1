########################################################
##
## Workspace.build.ps1
## Pip.Tasks - Cross platform project build system
## Workspace build script
##
#######################################################

param
(
    [string] $Path = $null,
    [hashtable]$Params = @{},
    [hashtable]$Properties = @{}
)

if ($Path -eq $null) { throw "Internal error: workspace location is not defined" }

Set-Location -Path $Path
$BuildPath = $Path

Write-Host ("`n" + ('-' * 7) + " Executing Workspace:$($BuildTask) " + ('-' * 7)) -ForegroundColor Yellow -BackgroundColor DarkGray

# Load scripts with standard imperative tasks
$fs = Get-ImperativeIncludes -Workspace
foreach ($f in $fs)
{
    . $f.File
}

# Create tasks with standard declarative tasks
$ns = Get-DeclarativeTaskNames -Workspace
foreach ($n in $ns)
{
    task $n {
        $t = Find-DeclarativeTask -Task $Task.Name
        if ($t -ne $null)
        {
            Invoke-Build -Task $t.Task -File $t.File
        }
    }
}

# Load scripts and properties
if (Test-Path -Path "./global.build.ps1") { . "./global.build.ps1" @Params }
if (Test-Path -Path "./workspace.build.ps1") { . "./workspace.build.ps1" @Params }
if (Test-Path -Path "./global.conf.ps1") { . "./global.conf.ps1" @Params }
if (Test-Path -Path "./workspace.conf.ps1") { . "./workspace.conf.ps1" @Params }

# Load overrides for scripts and properties
if (Test-Path -Path "./global.build.override.ps1") { . "./global.build.override.ps1" @Params }
if (Test-Path -Path "./workspace.build.override.ps1") { . "./workspace.build.override.ps1" @Params }
if (Test-Path -Path "./global.conf.override.ps1") {. "./global.conf.override.ps1" @Params }
if (Test-Path -Path "./workspace.conf.override.ps1") { . "./workspace.conf.override.ps1" @Params }

# Reapply command line properties
. Set-Properties -Properties $Properties -Override $true -Scope Local
