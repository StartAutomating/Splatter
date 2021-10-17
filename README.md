<div align='center'>
<img src='Assets/Splatter.png' />
[![Test Build And Publish](https://github.com/StartAutomating/Splatter/actions/workflows/TestBuildAndPublish.yml/badge.svg)](https://github.com/StartAutomating/Splatter/actions/workflows/TestBuildAndPublish.yml)
<h3>Simple Scripts to Supercharge Splatting</h3>
</div>

## Splatter is a simple Splatting toolkit

Splatting is a technique of passing parameters in PowerShell.

Splatter makes splatting more powerful, flexible, and easy to use.

With Splatter you can:
* Splat any object to any command
* Pipe splats to commands
* Validate splats 
* Find commands for a splat

Splatter is tiny, and can be easily embedded into any module, or used to generate splatting code.

### Using Splatter

Splatter has four core commands:
* Get-Splat (?@)
* Find-Splat (??@)
* Merge-Splat (*@)
* Use-Splat (.@)

#### Get-Splat

|   Alias   |       Variables            |
|-----------|----------------------------|
| ?@,gSplat | ${?@}, $gSplat, $GetSplat  |


Get-Splat returns a Dictionary of parameters, given a command or ScriptBlock.  
This only contains parameters for the command, and converts the parameters into the desired types.
Get-Splat can take any object or Dictionary as input.

    @{Id=$pid;Junk='Data'} | Get-Splat Get-Process    
    # -or 
    @{Id=$pid;Junk='Data'} | ?@ gps
    # -or
    @{Id=$pid;Junk='Data'} | & ${?@} gps


Get-Splat can take more than one command as input.
If it does, it will return the matching inputs for each command.        
    
    @{FilePath = 'pwsh';ArgumentList = '-noprofile';PassThru=$true} | 
        Use-Splat Start-Process |
        Add-Member NoteProperty TimeOut 15 -PassThru | 
        Get-Splat Wait-Process, Stop-Process

Get-Splat will also attach a properties to the Dictionary.  

These property won't be used when calling the splat, but can be peeked at:

|   Property    |   Description                                 |
|---------------|-----------------------------------------------|
|  Command      |           The Command                         |
|  CouldRun     |  If the command could run, given the splat    | 
|  Invalid      |  Parameters that are invalid                  |
|  Missing      |  Mandatory parameters that are missing        |
|  PercentFit   |  % of properties that map to parameters       |
|  Unmapped     |  Properties that don't map to parameters      |


    $splat = @{id=$pid;foo='bar'} | ?@ gps
    $splat.Command, $splat.PercentFit, $splat.Unmapped


#### Find-Splat
|   Alias    |       Variables            |
|------------|----------------------------|
| ??@,fSplat | ${??@}, $fSplat, $FindSplat|



Find-Splat will find commands that match a given splat, and return information about a match.

    @{id=$pid} | Find-Splat *-Process

Find-Splat may also be scoped to a given module

    @{splat=@{}} | Find-Splat -Module Splatter

#### Merge-Splat
|   Alias    |       Variables            |
|------------|----------------------------|
| *@,mSplat  | ${*@}, $mSplat, $MergeSplat|


Merge splat will merge multiple splats together.

    @{a='b'}, @{c='d'} | Merge-Splat


#### Use-Splat

|   Alias      |       Variables                  |
|--------------|----------------------------------|
| .@,uSplat    | ${.@},  $uSplat, $UseSplat       |


Use-Splat will run a splat against one or more commands.
    @{id=$pid} | Use-Splat Get-Process # Gets the current process

    # Gets the process, and then doesn't stop the process because Stop-Process is passed WhatIf
    @{id=$pid;WhatIf=$true} | .@ Get-Process,Stop-Process 


### Using Splatter with ScriptBlocks


In PowerShell, you can treat any ScriptBlock as a command.  Splatter makes this simpler.

Take this example, which takes a little bit of input data and uses it in a few different scripts.

    @{
        Name='James'
        Birthday = '12/17/1981'
        City = 'Seattle'
        State = 'Washington'
    } | .@ {
        param($Name)
        "$name"
    }, {
        param([DateTime]$Birthday)
        $ageTimespan = [DateTime]::Now - $birthday
        "Age:" + [Math]::Floor($ageTimespan.TotalDays / 365)
        
    }, {
        param($city, $state)
        "$city, $state"
    }

Since Splatter will also convert objects to hashtables, you could also write something like:

    Import-Csv .\People.csv | .@ 
        {
            param($Name)
            "$name"
        }, {
            param([DateTime]$Birthday)
            $ageTimespan = [DateTime]::Now - $birthday
            "Age:" + [Math]::Floor($ageTimespan.TotalDays / 365)
        
        }


### Embedding Splatter

Initialize-Splat will output a script containing the core commands for Splatter.
Using this output, you can directly embed Splatter into any script or module.

    Initialize-Splatter

To install this into a module:

    Get-Module TheNameOfYourModule | Split-Path | Push-Location    
    Initialize-Splatter > '@.ps1'
    Pop-Location

Then add the following line to your module:

    . $psScriptRoot\@.ps1

By default, when Splatter is embedded, it will not export functions or aliases, and you will need to use the variable syntax:

    & ${?@}  # Get-Splat
    & ${??@} # Find-Splat
    & ${*@}  # Merge-Splat
    & ${.@}  # Use-Splat     

You can override this by using -AsFunction

    Initialize-Splatter -AsFunction

If you don't need all of the commands, you can use -Verb

    Initialize-Splatter -Verb Get, Use



### Generating Splatting Code

You can use Out-Splat to generate code that splats.

    Out-Splat -CommandName Get-Command -DefaultParameter @{Module='Splatter';CommandType='Alias'} | Invoke-Expression

You can use also use Out-Splatter to generate whole functions, including help.

    $scriptBlock = 
        Out-Splat -FunctionName Get-SplatterAlias -CommandName Get-Command -DefaultParameter @{
            Module='Splatter';CommandType='Alias'
        } -ExcludeParameter * -Synopsis 'Gets Splatter Aliases' -Description 'Gets aliases from the module Splatter'
    . ([ScriptBlock]::Create($scriptBlock))

    Get-SplatterAlias | Out-String
    Get-Help Get-SplatterAlias | Out-String