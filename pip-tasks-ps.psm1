########################################################
##
## pip-tasks-ps.psm1
## Pip.Tasks - Cross platform project build system
## Startup module
##
#######################################################

$Global:PipTasksRoot = $PSScriptRoot

$path = $PSScriptRoot
if ($path -eq "") { $path = "." }

. "$path\src\Component.ps1"
. "$path\src\Workspace.ps1"
. "$path\src\Build.ps1"
. "$path\src\Files.ps1"
. "$path\src\Arguments.ps1"
. "$path\src\Properties.ps1"
. "$path\src\Execute.ps1"
. "$path\src\Platform.ps1"
. "$path\src\Includes.ps1"
. "$path\src\Declarations.ps1"

Set-Alias -Name "piptask" -Value "Invoke-Task" -Scope Global
Set-Alias -Name "pipcomp" -Value "Invoke-ComponentTask" -Scope Global
Set-Alias -Name "pipws" -Value "Invoke-WorkspaceTask" -Scope Global
Set-Alias -Name "pipuse" -Value "Use-Workspace" -Scope Global
Set-Alias -Name "pipshow" -Value "Get-Components" -Scope Global
