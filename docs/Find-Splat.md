Find-Splat
----------




### Synopsis
Finds commands that can be splatted to given an input.



---


### Description

Finds the commands whose input parameters match an input object, and returns an [ordered] dictionary of parameters.



---


### Related Links
* [Get-Splat](Get-Splat.md)



* [Use-Splat](Use-Splat.md)





---


### Examples
#### EXAMPLE 1
```PowerShell
@{Id=$pid} | Find-Splat -Global
```



---


### Parameters
#### **Command**

One or more commands.
If not provided, commands from the current module will be searched.
If there is no current module, all commands will be searched.






|Type        |Required|Position|PipelineInput|
|------------|--------|--------|-------------|
|`[String[]]`|false   |1       |false        |



#### **Splat**

The splat






|Type        |Required|Position|PipelineInput |Aliases    |
|------------|--------|--------|--------------|-----------|
|`[PSObject]`|false   |2       |true (ByValue)|InputObject|



#### **Global**

If set, will look for all commands, even if Find-Splat is used within a module.






|Type      |Required|Position|PipelineInput|Aliases|
|----------|--------|--------|-------------|-------|
|`[Switch]`|false   |named   |false        |G      |



#### **Local**

If set, will look for commands within the current module.
To make this work within your own module Install-Splat.






|Type      |Required|Position|PipelineInput|Aliases|
|----------|--------|--------|-------------|-------|
|`[Switch]`|false   |named   |false        |L      |



#### **Module**

If provided, will look for commands within any number of loaded modules.






|Type        |Required|Position|PipelineInput|Aliases|
|------------|--------|--------|-------------|-------|
|`[String[]]`|false   |named   |false        |M      |



#### **Force**

If set, will return regardless of if parameters map,  are valid, and have enough mandatory parameters






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |





---


### Syntax
```PowerShell
Find-Splat [[-Command] <String[]>] [[-Splat] <PSObject>] [-Global] [-Local] [-Module <String[]>] [-Force] [<CommonParameters>]
```
