########################################################
##
## Component.build.ps1
## Pip.Tasks - Cross platform project build system
## Component build script
##
#######################################################

param
(
    [string] $Path = $null,
    [hashtable] $Params = @{},
    [hashtable] $Properties = @{}
)

if ($Path -eq $null) { throw "Internal error: component location is not defined" }

Set-Location -Path $Path
$BuildPath = $Path

$ComponentName = $(Get-Item -Path $Path).Name
Write-Host ("`n" + ('-' * 7) + " Executing $($ComponentName):$($BuildTask) " + ('-' * 7)) -ForegroundColor Yellow -BackgroundColor DarkGray

# Load scripts with standard imperative tasks
$fs = Get-ImperativeIncludes -Component
foreach ($f in $fs)
{
    . $f.File
}

# Create tasks with standard declarative tasks
$ns = Get-DeclarativeTaskNames -Component
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
if (Test-Path -Path "../global.build.ps1") { . "../global.build.ps1" @Params }
if (Test-Path -Path "./component.build.ps1") { . "./component.build.ps1" @Params }
if (Test-Path -Path "../global.conf.ps1") { . "../global.conf.ps1" @Params }
if (Test-Path -Path "./component.conf.ps1") { . "./component.conf.ps1" @Params }

# Load overrides for scripts and properties
if (Test-Path -Path "../global.build.override.ps1") { . "../global.build.override.ps1" @Params }
if (Test-Path -Path "./component.build.override.ps1") { . "./component.build.override.ps1" @Params }
if (Test-Path -Path "../global.conf.override.ps1") {. "../global.conf.override.ps1" @Params }
if (Test-Path -Path "./component.conf.override.ps1") { . "./component.conf.override.ps1" @Params }

# Reapply command line properties
. Set-Properties -Properties $Properties -Override $true -Scope Local
