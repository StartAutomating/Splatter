Get-Splat
---------




### Synopsis
Gets a splat



---


### Description

Gets a splat for a command



---


### Related Links
* [Find-Splat](Find-Splat.md)



* [Use-Splat](Use-Splat.md)





---


### Examples
#### EXAMPLE 1
```PowerShell
@{id=$pid} | Get-Splat
```

#### EXAMPLE 2
```PowerShell
@{id=$Pid} | ?@ # ?@ is an alias for Get-Splat
```

#### EXAMPLE 3
```PowerShell
@{id=$pid} | & ${?@} # Get-Splat as a script block
```



---


### Parameters
#### **Command**

The command that is being splatted.






|Type          |Required|Position|PipelineInput|
|--------------|--------|--------|-------------|
|`[PSObject[]]`|true    |1       |false        |



#### **Splat**

The input object






|Type        |Required|Position|PipelineInput |Aliases    |
|------------|--------|--------|--------------|-----------|
|`[PSObject]`|true    |2       |true (ByValue)|InputObject|



#### **Force**

If set, will return regardless of if parameters map,  are valid, and have enough mandatory parameters






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |





---


### Syntax
```PowerShell
Get-Splat [-Command] <PSObject[]> [-Splat] <PSObject> [-Force] [<CommonParameters>]
```
