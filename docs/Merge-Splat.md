Merge-Splat
-----------




### Synopsis
Merges one or more splats



---


### Description

Merges one or more hashtables and property bags into one [ordered] hashtable.
Allows you to -Remove specific keys from any object
Allows you to -Include or -Exclude wildcards of keys (or patterns, with -RegularExpression)
Allows you to -Map additional values if a value if found.



---


### Related Links
* [Get-Splat](Get-Splat.md)



* [Use-Splat](Use-Splat.md)





---


### Examples
#### EXAMPLE 1
```PowerShell
@{a='b'}, @{c='d'} | Merge-Splat
```

#### EXAMPLE 2
```PowerShell
[PSCustomOBject]@{a='b'}, @{c='d'} | Merge-Splat -Add @{e='f'} -Remove c
```

#### EXAMPLE 3
```PowerShell
@{id=$pid} |
    Use-Splat Get-Process |
    Merge-Splat -Include Name
```

#### EXAMPLE 4
```PowerShell
@{n=$(Get-Random) } |
    Merge-Splat -Map @{
        N = {
            if (-not ($_ % 2)) { @{IsEven=$true;IsOdd=$false} }
            else { @{IsEven=$false;IsOdd=$true}}
        }
    }
```



---


### Parameters
#### **Splat**

The splat






|Type          |Required|Position|PipelineInput |Aliases    |
|--------------|--------|--------|--------------|-----------|
|`[PSObject[]]`|false   |named   |true (ByValue)|InputObject|



#### **Add**

Splats or objects that will be added to the splat.






|Type          |Required|Position|PipelineInput|Aliases               |
|--------------|--------|--------|-------------|----------------------|
|`[PSObject[]]`|false   |1       |false        |With<br/>W<br/>A<br/>+|



#### **Remove**

The names of the keys to remove from the splat






|Type        |Required|Position|PipelineInput|Aliases                          |
|------------|--------|--------|-------------|---------------------------------|
|`[String[]]`|false   |named   |false        |Delete<br/>Drop<br/>D<br/>R<br/>-|



#### **Include**

Patterns of names to include in the splat.
If provided, only keys that match at least one -Include pattern will be kept.
By default, these are wildcards, unlesss -RegularExpression is passed.






|Type        |Required|Position|PipelineInput|Aliases |
|------------|--------|--------|-------------|--------|
|`[String[]]`|false   |named   |false        |E<br/>EX|



#### **Exclude**

Patterns of names to exclude from the splat.
By default, these are wildcards, unlesss -RegularExpression is passed.






|Type        |Required|Position|PipelineInput|Aliases |
|------------|--------|--------|-------------|--------|
|`[String[]]`|false   |named   |false        |I<br/>IN|



#### **RegularExpression**

If set, all patterns matched will be assumed to be RegularExpressions, not wildcards






|Type      |Required|Position|PipelineInput|Aliases     |
|----------|--------|--------|-------------|------------|
|`[Switch]`|false   |named   |false        |Regex<br/>RX|



#### **Map**

A map of new data to add.  The key is the name of the original property.
The value can be any a string, a hashtable, or a script block.
If the value is a string, it will be treated as a key, and the original property will be copied to this key.
If the value is a hashtable, it will add the values contained in Map.
If the value is a ScriptBlock, it will combine the output of this script block with the splat.






|Type           |Required|Position|PipelineInput|Aliases    |
|---------------|--------|--------|-------------|-----------|
|`[IDictionary]`|false   |named   |false        |M<br/>ReMap|



#### **Keep**

If set, will keep existing values in a splat instead of adding it to a list of values.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Replace**

If set, will replace existing values in a splat instead of adding it to a list of values.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |





---


### Syntax
```PowerShell
Merge-Splat [-Splat <PSObject[]>] [[-Add] <PSObject[]>] [-Remove <String[]>] [-Include <String[]>] [-Exclude <String[]>] [-RegularExpression] [-Map <IDictionary>] [-Keep] [-Replace] [<CommonParameters>]
```
