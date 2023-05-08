Out-Splat
---------




### Synopsis
Outputs code that splats



---


### Description

Outputs a function or script that primarily calls another command.  This can get messy to write by hand.



---


### Related Links
* [Initialize-Splatter](Initialize-Splatter.md)





---


### Examples
#### EXAMPLE 1
```PowerShell
Out-Splat -CommandName Get-Command
```

#### EXAMPLE 2
```PowerShell
Out-Splat -FunctionName Get-MyProcess -Example Get-MyProcess -CommandName Get-Process -DefaultParameter @{
    Id = '$pid'
} -ExcludeParameter *
```



---


### Parameters
#### **CommandName**

The name of the command that will be splatted






|Type      |Required|Position|PipelineInput        |Aliases|
|----------|--------|--------|---------------------|-------|
|`[String]`|true    |1       |true (ByPropertyName)|Name   |



#### **DefaultParameter**

A hashtable of default parameters.  These will always be passed to the underlying command by name.






|Type         |Required|Position|PipelineInput        |Aliases          |
|-------------|--------|--------|---------------------|-----------------|
|`[Hashtable]`|false   |2       |true (ByPropertyName)|DefaultParameters|



#### **ArgumentList**

A list of arguments.  These will be always be passed to the underlying commands by position.
Items starting with $ will be treated as a variable.






|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[String[]]`|false   |named   |true (ByPropertyName)|



#### **InputParameter**

A list of parameters names that will be inputted from the original command into the splat.
If generating a function, these parameter declarations will be copied from the underlying command.
Help for these parameters will be included as comment-based help






|Type        |Required|Position|PipelineInput        |Aliases         |
|------------|--------|--------|---------------------|----------------|
|`[String[]]`|false   |4       |true (ByPropertyName)|IncludeParameter|



#### **ExcludeParameter**

A list of parameters that will be excluded from the original function.
This is only valid when generating a function.
Wildcards may be used.






|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[String[]]`|false   |5       |true (ByPropertyName)|



#### **DefaultOverride**

If set, values from input parameters will override default values.






|Type      |Required|Position|PipelineInput        |Aliases                                                  |
|----------|--------|--------|---------------------|---------------------------------------------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|OverrideDefault<br/>OverwriteDefault<br/>DefaultOverwrite|



#### **VariableInput**

If set, any variable with a non-null value matching the input parameters will be used to splat.
If not set, only bound parameters will be used to splat.
If no function name is provided, this will automatically be set






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|



#### **VariableName**

The name of the variable used to hold the splatted parameters.  By default, ${CommandName}Parameters (e.g. GetHelpP






|Type      |Required|Position|PipelineInput        |Aliases  |
|----------|--------|--------|---------------------|---------|
|`[String]`|false   |named   |true (ByPropertyName)|SplatName|



#### **FunctionName**

An optional name of a generated function.
If provided, this function will declare any input parameters specified in -InputParameter






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|true    |3       |true (ByPropertyName)|



#### **Synopsis**

The synopsis.
This is used to make comment-based help in a generated function.
By default, it is : "Wraps $CommandName"






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |named   |true (ByPropertyName)|



#### **Description**

The description.
This is used to make comment-based help in a generated function.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |named   |true (ByPropertyName)|



#### **Example**

One or more examples.
This is used to make comment-based help in a generated function.






|Type        |Required|Position|PipelineInput        |Aliases |
|------------|--------|--------|---------------------|--------|
|`[String[]]`|false   |named   |true (ByPropertyName)|Examples|



#### **Link**

One or more links.
This is used to make comment-based help in a generated function.






|Type        |Required|Position|PipelineInput        |Aliases|
|------------|--------|--------|---------------------|-------|
|`[String[]]`|false   |named   |true (ByPropertyName)|Links  |



#### **Note**

Some notes.
This is used to make comment-based help in a generated function.






|Type      |Required|Position|PipelineInput        |Aliases|
|----------|--------|--------|---------------------|-------|
|`[String]`|false   |named   |true (ByPropertyName)|Notes  |



#### **CmdletBinding**

The CmdletBinding attribute for a new function






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[String]`|false   |named   |true (ByPropertyName)|



#### **OutputType**

The [OutputType()] of a function.  
If the type resolves to a [type], it's value will be provided as a [type].  
Otherwise, it will be provided as a [string]






|Type        |Required|Position|PipelineInput        |
|------------|--------|--------|---------------------|
|`[String[]]`|false   |named   |true (ByPropertyName)|



#### **AdditionalParameter**

A set of additional parameter declarations.
The keys are the names of the parameters, and the values can be a type and a string containing parameter binding and inline help.






|Type         |Required|Position|PipelineInput        |
|-------------|--------|--------|---------------------|
|`[Hashtable]`|false   |named   |true (ByPropertyName)|



#### **SerializationDepth**

The serialization depth for default parameters.  By default, 2.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[UInt32]`|false   |named   |false        |



#### **DynamicParameter**

If set, will generate the code to collect the -CommandName input as dynamic parameters.






|Type      |Required|Position|PipelineInput|Aliases          |
|----------|--------|--------|-------------|-----------------|
|`[Switch]`|true    |named   |false        |DynamicParameters|



#### **Unpiped**

If set, will not allow dynamic parameters to use ValueFromPipeline or ValueFromPipelineByPropertyName






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Offset**

If provided, will offset the position of any positional parameters.






|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |named   |false        |



#### **NewParameterSetName**

If provided, dynamic parameters will be created in a new parameter set, named $NewParameterSetName.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |named   |false        |



#### **CrossStream**

If set, will cross errors into the output stream.
You SHOULD cross the streams when dealing with console applications, as many of them like to return output on standard error.






|Type      |Required|Position|PipelineInput        |
|----------|--------|--------|---------------------|
|`[Switch]`|false   |named   |true (ByPropertyName)|



#### **Where**

A script block used to filter the results






|Type           |Required|Position|PipelineInput|
|---------------|--------|--------|-------------|
|`[ScriptBlock]`|false   |named   |false        |



#### **Begin**

A script to run before the splatter starts






|Type           |Required|Position|PipelineInput|
|---------------|--------|--------|-------------|
|`[ScriptBlock]`|false   |named   |false        |



#### **Process**

A script to run on each splatter result






|Type           |Required|Position|PipelineInput|
|---------------|--------|--------|-------------|
|`[ScriptBlock]`|false   |named   |false        |



#### **End**

A script to run after the splat is over






|Type           |Required|Position|PipelineInput|
|---------------|--------|--------|-------------|
|`[ScriptBlock]`|false   |named   |false        |



#### **PipeTo**

If provided, will pipe directly into the contents of this script block.
This assumes that the first item in the script block is a command, and it will accept the output of the splat as pipelined input






|Type           |Required|Position|PipelineInput|Aliases          |
|---------------|--------|--------|-------------|-----------------|
|`[ScriptBlock]`|false   |named   |false        |PipeInto<br/>Pipe|





---


### Outputs
* [Management.Automation.ScriptBlock](https://learn.microsoft.com/en-us/dotnet/api/System.Management.Automation.ScriptBlock)






---


### Syntax
```PowerShell
Out-Splat [-CommandName] <String> [[-DefaultParameter] <Hashtable>] [-ArgumentList <String[]>] [[-InputParameter] <String[]>] [[-ExcludeParameter] <String[]>] [-DefaultOverride] [-VariableInput] [-VariableName <String>] [-SerializationDepth <UInt32>] [-CrossStream] [-Where <ScriptBlock>] [-Begin <ScriptBlock>] [-Process <ScriptBlock>] [-End <ScriptBlock>] [-PipeTo <ScriptBlock>] [<CommonParameters>]
```
```PowerShell
Out-Splat [-CommandName] <String> [[-DefaultParameter] <Hashtable>] [-ArgumentList <String[]>] [[-InputParameter] <String[]>] [[-ExcludeParameter] <String[]>] [-DefaultOverride] [-VariableInput] [-VariableName <String>] [-FunctionName] <String> [-Synopsis <String>] [-Description <String>] [-Example <String[]>] [-Link <String[]>] [-Note <String>] [-CmdletBinding <String>] [-OutputType <String[]>] [-AdditionalParameter <Hashtable>] [-SerializationDepth <UInt32>] [-CrossStream] [-Where <ScriptBlock>] [-Begin <ScriptBlock>] [-Process <ScriptBlock>] [-End <ScriptBlock>] [-PipeTo <ScriptBlock>] [<CommonParameters>]
```
```PowerShell
Out-Splat [-CommandName] <String> [[-DefaultParameter] <Hashtable>] [-ArgumentList <String[]>] [[-InputParameter] <String[]>] [[-ExcludeParameter] <String[]>] [-DefaultOverride] [-VariableInput] [-VariableName <String>] [-SerializationDepth <UInt32>] -DynamicParameter [-Unpiped] [-Offset <Int32>] [-NewParameterSetName <String>] [-CrossStream] [-Where <ScriptBlock>] [-Begin <ScriptBlock>] [-Process <ScriptBlock>] [-End <ScriptBlock>] [-PipeTo <ScriptBlock>] [<CommonParameters>]
```
