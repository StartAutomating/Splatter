Initialize-Splatter
-------------------




### Synopsis
Initializes an embeddable version of Splatter



---


### Description

Initialize-Splatter enables you to embed Splatter into any module.



---


### Related Links
* [Get-Splat](Get-Splat.md)



* [Find-Splat](Find-Splat.md)



* [Use-Splat](Use-Splat.md)



* [Merge-Splat](Merge-Splat.md)





---


### Examples
#### EXAMPLE 1
```PowerShell
'@.ps1' # Initialize Splatter
```

#### EXAMPLE 2
```PowerShell
'@.ps1'
```

#### EXAMPLE 3
```PowerShell
'@.ps1' # Initialize splatter
```



---


### Parameters
#### **Verb**

The verbs to install.



Valid Values:

* Get
* Use
* Find
* Merge
* Out






|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[String[]]`|false   |1       |true (ByPropertyName)|



#### **Compress**

If set, will not compress the definitions






|Type      |Required|Position|PipelineInput        |Aliases      |
|----------|--------|--------|---------------------|-------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|NoCompression|



#### **Minify**

If set, will not minify the definitions






|Type      |Required|Position|PipelineInput        |Aliases       |
|----------|--------|--------|---------------------|--------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|NoMinification|



#### **NoLogo**

If set, will not add a line of documentation linking to the module






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|



#### **NoHelp**

If set, will strip inline help from the commands.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|



#### **AsFunction**

If set, will define the commands as functions and define aliases.
If you use this, please use the manifest or Export-ModuleMember to hide Splatter's commands.
If not set, Splatter will install as ScriptBlocks (these will not be exported from a module)






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Inline**

If set, splatter will be defined inline.
This will not preface Splatter with a param() block and PSScriptAnalyzer suppression messages






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **OutputPath**

The output path.
If provided, will output to this file and return the file.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |





---


### Syntax
```PowerShell
Initialize-Splatter [[-Verb] <String[]>] [-Compress] [-Minify] [-NoLogo] [-NoHelp] [-AsFunction] [-Inline] [[-OutputPath] <String>] [<CommonParameters>]
```
