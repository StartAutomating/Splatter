Use-Splat
---------




### Synopsis
Uses a splat.



---


### Description

Uses a splat to call a command.
If passed from Find-Splat,Get-Splat or Test-Splat, the command will be automatically detected.
If called as .@, this will run only provided commands
If called as *@, this will run any found commands



---


### Related Links
* [Get-Splat](Get-Splat.md)



* [Find-Splat](Find-Splat.md)



* [Test-Splat](Test-Splat.md)





---


### Examples
#### EXAMPLE 1
```PowerShell
@{id=$pid} | Use-Splat gps # When calling Use-Splat is globally imported
```

#### EXAMPLE 2
```PowerShell
@{id=$pid} | & ${.@} gps # When calling Use-Splat is nested
```

#### EXAMPLE 3
```PowerShell
@{LogName='System';InstanceId=43,44},
@{LogName='Application';InstanceId=10000,10005} |
    .@ Get-EventLog # get a bunch of different log events
```



---


### Parameters
#### **Command**

One or more commands






|Type          |Required|Position|PipelineInput|
|--------------|--------|--------|-------------|
|`[PSObject[]]`|false   |1       |false        |



#### **ArgumentList**

Any additional positional arguments that would be passed to the command






|Type          |Required|Position|PipelineInput|
|--------------|--------|--------|-------------|
|`[PSObject[]]`|false   |2       |false        |



#### **Splat**

The splat






|Type          |Required|Position|PipelineInput |
|--------------|--------|--------|--------------|
|`[PSObject[]]`|false   |named   |true (ByValue)|



#### **Force**

If set, will run regardless of if parameters map, are valid, and have enough mandatory parameters.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Best**

If set, will run the best fit out of multiple commands.
The best fit is the command that will use the most of the input splat.






|Type      |Required|Position|PipelineInput|Aliases                                   |
|----------|--------|--------|-------------|------------------------------------------|
|`[Switch]`|false   |named   |false        |BestFit<br/>BestFitFunction<br/>BF<br/>BFF|



#### **Stream**

If set, will stream input into a single pipeline of each command.
The non-pipeable parameters of the first input splat will be used to start the pipeline.
By default, a command will be run once per input splat.






|Type      |Required|Position|PipelineInput|Aliases|
|----------|--------|--------|-------------|-------|
|`[Switch]`|false   |named   |false        |Pipe   |





---


### Syntax
```PowerShell
Use-Splat [[-Command] <PSObject[]>] [[-ArgumentList] <PSObject[]>] [-Splat <PSObject[]>] [-Force] [-Best] [-Stream] [<CommonParameters>]
```
