# <img src="https://github.com/pip-tasks/pip-tasks/raw/master/artifacts/logo.png" alt="Pip.Devs Logo" style="max-width:30%"> <br/> Cross platform project build system in Powershell

Modern projects often contain multiple components: microservices, APIs, client applications, utility tools. 
They may be written in different languages and run on multiple platforms. Each language, platform and operating system
has different set of tools and procedures to build, test and deploy those components. That makes developers' life quite complicated.

Powershell is a unique scripting language created as a replacement for traditional shells scripts. It brings power of object-oriented
general purpose languages into scripts in easy to use form. Starting from version 6.0 it is available on Windows, Linux and Mac. 
That makes Powershell an excellent choice for automation tool of devops tasks. [Psake](https://github.com/psake/psake) 
and [Invoke-Build](https://github.com/nightroman/Invoke-Build) are two most popular build tools entirely written in Powershell.

The aim for **Pip.Tasks** is to take Powershell builds to the next level, and allow to automate build of complex projects 
consisted of multiple heterogenous components. It is developed on the top of the excellent **Invoke-Build** and does the following:
* Structures projects as *workspaces* that contain one or many *components*. Build tasks can be run for one, several or all components, or for the entire workspace
* Supports *imperative* tasks written in **Invoke-Build** or *declarative* tasks executed by prebuilt tasks according to build configuration
* Mechanism of configuration and task overrides allows to tailor builds to local environment without introducing breaking changes into build scripts

There is a growing number of tasks you can use in your builds
* [pip-tasks-common](https://github.com/pip-tasks/pip-tasks-common) - common tasks for Git, Npm, Typescript
* [pip-tasks-dotnet](https://github.com/pip-tasks/pip-tasks-dotnet) - .NET specific tasks for Nuget, Visual Studio and Service Fabric 
* [pip-tasks-java](https://github.com/pip-tasks/pip-tasks-java) - Java specific tasks for Maven and Java 
* [pip-tasks-js](https://github.com/pip-tasks/pip-tasks-js) - Javascript and Node.js specific tasks for Npm, Typescript, Mocha
* [pip-tasks-python](https://github.com/pip-tasks/pip-tasks-python) - Python specific tasks for Python, Pip, PyTest
* [pip-tasks-all](https://github.com/pip-tasks/pip-tasks-all) - All above tasks 

Project workspace on the local disk has the following files and folders
```bash
/<workspace> - workflow root folder    
    /<component1>
        ...
        component.conf.ps1           - component configuration properties
        component.conf.override.ps1  - local overrides for component configuration
        component.build.ps1          - component build tasks
        component.build.override.ps1 - local overrides for component build tasks
    /<component2>
        ...
    /<componentN>
        ...
    environment.ps1           - environment startup script
    global.conf.ps1           - global configuration properties shared for workspace and components
    global.conf.override.ps1  - local overrides for global configuration
    global.build.ps1          - global build tasks shared for workspace and components
    global.build.override.ps1 - local overrides for global build tasks
    workspace.conf.ps1           - workspace configuration properties
    workspace.conf.override.ps1  - local overrides for workspace configuration
    workspace.build.ps1          - workspace build tasks
    workspace.build.override.ps1 - local overrides for workspace build tasks    
```

## Usage

Here is a typical Pip.Tasks usage scenario:

1. Create workspace folder, place inside **workspace.conf.ps1** file and configure there component repositories
```powershell
$VersionControl = 'git'
$VersionControlRepos = @(
    "https://my.visualstudio.com/DefaultCollection/MyProject/_git/component1",
    "https://my.visualstudio.com/DefaultCollection/MyProject/_git/component2",
    "https://my.visualstudio.com/DefaultCollection/MyProject/_git/component3"
)
$Deploy = 'servicefabric'
$DeployUri = 'localhost:19000'
```
Alternatively, you can keep and checkout workspace from version control repository

2. Set default workspace
```powershell
Use-Workspace -Path <path to workspace>
```

3. Clone component repositories defined as step 1 into the workspace
```powershell
Invoke-Task Clone -Workspace
```
Each component must have configuration, build tasks or both

4. Download external dependencies for all components
```powershell
Invoke-Task InstallDep -All
```

5. Build all components
```powershell
Invoke-Task Build -BuildConfig Debug -All
```

6. Test all components
```powershell
Invoke-Task Test -All
```

7. Clean up server and deploy component there
```powershell
Invoke-Task ResetServer -Uri localhost:19000
Invoke-Task Deploy -Component component1
```

## Installation

* Checkout **pip-tasks** and, optionally, pluggable build tasks like **pip-tasks-common** or **pip-tasks-dotnet** into local folder
* Add the folder to **PSModulePath**
* Import **pip-tasks** module and pluggable build tasks

## Acknowledgements

This module created and maintained by **Sergey Seroukhov**

Many thanks to contibutors, who put their time and talant into making this project better:
* **Nick Jimenez, BootBarn Inc.**

Many thanks to **Roman Kuzmin**, the author of **Invoke-Build** for the excellent, professionally written piece of software