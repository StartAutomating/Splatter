function Out-Splat
{
    <#
    .Synopsis
        Outputs code that splats
    .Description
        Outputs a function or script that primarily calls another command.  This can get messy to write by hand.
    .Link
        Initialize-Splatter
    .Example
        Out-Splat -CommandName Get-Command
    .Example
        Out-Splat -FunctionName Get-MyProcess -Example Get-MyProcess -CommandName Get-Process -DefaultParameter @{
            Id = '$pid'
        } -ExcludeParameter * 
    #>
    [CmdletBinding(DefaultParameterSetName='JustTheSplatter')]
    [Alias('=>@','oSplat')]
    [OutputType([ScriptBlock])]
    param(
    # The name of the command that will be splatted
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName)]
    [Alias('Name')]
    [string]
    $CommandName,

    # A hashtable of default parameters.  These will always be passed to the underlying command by name.
    [Parameter(Position=1,ValueFromPipelineByPropertyName)]
    [Alias('DefaultParameters')]
    [Hashtable]
    $DefaultParameter = @{},

    # A list of arguments.  These will be always be passed to the underlying commands by position.
    # Items starting with $ will be treated as a variable.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string[]]
    $ArgumentList,

    # A list of parameters names that will be inputted from the original command into the splat.
    # If generating a function, these parameter declarations will be copied from the underlying command.
    # Help for these parameters will be included as comment-based help
    [Parameter(Position=3,ValueFromPipelineByPropertyName)]
    [Alias('IncludeParameter')]
    [string[]]
    $InputParameter,

    # A list of parameters that will be excluded from the original function.
    # This is only valid when generating a function.
    # Wildcards may be used.
    [Parameter(Position=4,ValueFromPipelineByPropertyName)]
    [string[]]
    $ExcludeParameter,

    # If set, values from input parameters will override default values.
    [Alias('OverrideDefault','OverwriteDefault', 'DefaultOverwrite')]
    [Parameter(ValueFromPipelineByPropertyName)]
    [Switch]
    $DefaultOverride,

    # If set, any variable with a non-null value matching the input parameters will be used to splat.
    # If not set, only bound parameters will be used to splat.
    # If no function name is provided, this will automatically be set
    [Parameter(ValueFromPipelineByPropertyName)]
    [Switch]
    $VariableInput,

    # The name of the variable used to hold the splatted parameters.  By default, ${CommandName}Parameters (e.g. GetHelpP
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('SplatName')]
    [string]
    $VariableName,

    # An optional name of a generated function.
    # If provided, this function will declare any input parameters specified in -InputParameter
    [Parameter(Mandatory=$true,Position=2,ValueFromPipelineByPropertyName,ParameterSetName='FunctionalSplatter')]
    [string]
    $FunctionName,

    # The synopsis.
    # This is used to make comment-based help in a generated function.
    # By default, it is : "Wraps $CommandName"
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='FunctionalSplatter')]
    [string]
    $Synopsis,

    # The description.
    # This is used to make comment-based help in a generated function.
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='FunctionalSplatter')]
    [string]
    $Description,

    # One or more examples.
    # This is used to make comment-based help in a generated function.
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='FunctionalSplatter')]
    [Alias('Examples')]
    [string[]]
    $Example,

    # One or more links.
    # This is used to make comment-based help in a generated function.
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='FunctionalSplatter')]
    [Alias('Links')]
    [string[]]
    $Link,

    # Some notes.
    # This is used to make comment-based help in a generated function.
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='FunctionalSplatter')]
    [Alias('Notes')]
    [string]
    $Note,

    # The CmdletBinding attribute for a new function
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='FunctionalSplatter')]
    [string]
    $CmdletBinding,

    # The [OutputType()] of a function.  
    # If the type resolves to a [type], it's value will be provided as a [type].  
    # Otherwise, it will be provided as a [string]
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='FunctionalSplatter')]
    [string[]]
    $OutputType,

    # A set of additional parameter declarations.
    # The keys are the names of the parameters, and the values can be a type and a string containing parameter binding and inline help.
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='FunctionalSplatter')]
    [Hashtable]
    $AdditionalParameter,

    # The serialization depth for default parameters.  By default, 2.
    [uint32]
    $SerializationDepth = 2,


    # If set, will generate the code to collect the -CommandName input as dynamic parameters.
    [Parameter(Mandatory,ParameterSetName='DynamicSplatter')]
    [Alias('DynamicParameters')]
    [switch]
    $DynamicParameter,

    # If set, will not allow dynamic parameters to use ValueFromPipeline or ValueFromPipelineByPropertyName
    [Parameter(ParameterSetName='DynamicSplatter')]
    [switch]
    $Unpiped,

    # If provided, will offset the position of any positional parameters.
    [Parameter(ParameterSetName='DynamicSplatter')]
    [int]
    $Offset,

    # If provided, dynamic parameters will be created in a new parameter set, named $NewParameterSetName.
    [Parameter(ParameterSetName='DynamicSplatter')]
    [string]
    $NewParameterSetName,

    # If set, will cross errors into the output stream.
    # You SHOULD cross the streams when dealing with console applications, as many of them like to return output on standard error.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Switch]
    $CrossStream,

    # A script block used to filter the results
    [ScriptBlock]$Where,

    # A script to run before the splatter starts
    [ScriptBlock]$Begin,

    # A script to run on each splatter result
    [ScriptBlock]$Process,

    # A script to run after the splat is over
    [ScriptBlock]$End,

    # If provided, will pipe directly into the contents of this script block.
    # This assumes that the first item in the script block is a command, and it will accept the output of the splat as pipelined input
    [ScriptBlock]
    [Alias('PipeInto','Pipe')]
    $PipeTo)

    process {
        # First, let's find the command.
        $commandExists = $ExecutionContext.SessionState.InvokeCommand.GetCommand($CommandName, 'All')

        if (-not $commandExists) { # If we don't, error out.
            Write-Error "$CommandName does not exist"
            return
        }

        if ($InputParameter.Count -eq 1 -and $InputParameter -eq '*') {
            if ($commandExists -is [Management.Automation.ApplicationInfo]) {
                $InputParameter = @()
            } else {
                $InputParameter = ($commandExists -as [Management.Automation.CommandMetaData]).Parameters.Keys
            }
        }

        if ($DynamicParameter) {
            if (-not $VariableName) {  # If no -VariableName was provided,
                $VariableName = "$($CommandName -replace '[\W\s]','')DynamicParameters" # default to ${CommandName}DynamicParameters
            }
            $safeCommandName = $($CommandName -replace '[\W\s]','')

            return [ScriptBlock]::Create(@(
            "if (-not `$$VariableName) {
    `$$VariableName = [Management.Automation.RuntimeDefinedParameterDictionary]::new()"
            "    `$$($CommandName -replace '[\W\s]','') = `$executionContext.SessionState.InvokeCommand.GetCommand('$CommandName', 'All')"
            $inputForeach =
                if ($InputParameter) {
                    "'$(@(:nextInputParameter foreach ($in in $InputParameter) {
                        foreach ($ex in $ExcludeParameter) {
                            if ($in -like $ex) { continue nextInputParameter }
                        }
                        $in
                    }) -join "','")'"
                } else {
                    "([Management.Automation.CommandMetaData]`$$safeCommandName).Parameters.Keys"
                }
            "    :nextInputParameter foreach (`$in in $inputForeach) {
        $(if ($ExcludeParameter) {
                "foreach (`$ex in '$($ExcludeParameter -join "','")') {
            if (`$in -like `$ex) { continue nextInputParameter }
        }
"})
        `$$variableName.Add(`$in, [Management.Automation.RuntimeDefinedParameter]::new(
            `$$SafeCommandName.Parameters[`$in].Name,
            `$$SafeCommandName.Parameters[`$in].ParameterType,
            `$$SafeCommandName.Parameters[`$in].Attributes
        ))
    }"
            if ($Unpiped -or $Offset -or $NewParameterSetName) {
"    foreach (`$paramName in `$$variableName.Keys) {
        foreach (`$attr in `$$variableName[`$paramName].Attributes) {
$(@(
            if ($Unpiped) {
'             if ($attr.ValueFromPipeline) {$attr.ValueFromPipeline = $false}'
'             if ($attr.ValueFromPipelineByPropertyName) {$attr.ValueFromPipelineByPropertyName = $false}'
            }
            if ($Offset) {
"             if (`$attr.Position -ge 0) { `$attr.Position += $offset }"
            }
            if ($NewParameterSetName) {
"             if (`$attr.psobject.properties('ParameterSetName')) { `$attr.ParameterSetName = '$NewParameterSetName' }"
            }
            )  -join [Environment]::NewLine)
        }
    }"
            }
            '}'
            "`$$variableName"

            ) -join [Environment]::NewLine)
        }

        if (-not $VariableName) {  # Next, if no -VariableName was provided,
            $VariableName = "$($CommandName -replace '[\W\s]','')Parameters"
        }

        $defaultDeclaration =
            if ($DefaultParameter.Count) {
                $toSplat = "@'
$(ConvertTo-Json $DefaultParameter -Depth $SerializationDepth)
'@"
                "`$${VariableName}Default = ConvertFrom-Json $toSplat"
                "`$$VariableName = @{}"
                "foreach (`$property in `$${VariableName}Default.psobject.properties) {
    `$$VariableName[`$property.Name] = `$property.Value
    if (`$property.Value -is [string] -and `$property.Value.StartsWith('`$')) {
        `$$VariableName[`$property.Name] = `$executionContext.SessionState.PSVariable.Get(`$property.Value.Substring(1)).Value
    }
}"
            } elseif ($ArgumentList.Count) {
                "`$$VariableName = " + @(foreach ($a in $ArgumentList) {
                    if ($a.StartsWith('$')) {
                        $a
                    } else {
                        "'$($a.Replace("'","''"))'"
                    }
                }) -join ','
            } else {
                "`$$VariableName = @{}"
            }

        if (-not $FunctionName) { $VariableInput = $true }

        $paramSplat =
        if ($InputParameter -or $FunctionName) {
            if ($VariableInput) {
"
#region Copy Parameters from $CommandName
foreach (`$in in '$($inputParameter -join "','")') {
    `$var = `$executionContext.SessionState.PSVariable.Get(`$in)
    if (-not `$var) { continue }
    $(if ($DefaultOverride) {
    "`$$VariableName.`$in = `$var.Value"
    } else {
    "`$$VariableName.`$in = `$var.Value"
    })
}
#endregion Copy Parameters from $CommandName
"
            } else {
                "#region Copy Parameters from $CommandName
`$MyParameters = [Ordered]@{} + `$psBoundParameters # Copy `$PSBoundParameters
foreach (`$in in $(if ($inputParameter) { "'$($inputParameter -join "','")'" } else { "`$MyParameters.Keys`"})) {
    $(if ($DefaultOverride) {
    "if (`$myParameters.`$in) {
        `$$VariableName.`$in = `$myParameters.`$in
    }"
    } else {
    "if (-not `$$VariableName.`$in -and `$myParameters.`$in) {
        `$$VariableName.`$in = `$myParameters.`$in
    }"})
}
#endregion Copy Parameters from $CommandName
"
            }
        } else {
             @()
        }

        $paramSplat = $paramSplat -join ([Environment]::NewLine)

        $cmdDef =
            if ([Management.Automation.ExternalScriptInfo],[Management.Automation.ApplicationInfo]  -contains $commandExists.GetType()) {
                " & '$($commandExists.Source.Replace("'","''"))' @$VariableName"
            } else {
                "$commandExists @$VariableName"
            }

        if ($CrossStream) {
            $cmdDef += " *>&1"
        }

        if ($Where) {
            $cmdDef += " |
    Where-Object {$Where}"
        }

        if ($PipeTo) {
            $cmdDef += "| $PipeTo"
        }

        if ($Begin -or $Process -or $End) {
            $cmdDef += " |
    Foreach-Object$(if ($Begin) { " -Begin {
        $Begin
    }"})$(if ($Process) { " -Process {
        $Process
    }"})$(if ($End) { " -End {
        $end
    }"})"
        }

        $coreSplat = (@() + $defaultDeclaration + $paramSplat + $cmdDef) -join ([Environment]::NewLine)


        if ($FunctionName) {
            $commandMeta = $commandExists -as [Management.Automation.CommandMetadata]

            foreach ($k in @($commandMeta.Parameters.Keys)) {
                if ($InputParameter -notcontains $k) {
                    $null =$commandMeta.Parameters.Remove($k)
                }
            }
            $originalCmdletBinding = [Management.Automation.Proxycommand]::GetCmdletBindingAttribute($commandExists)
            $cmdHelp = Get-Help -Name $commandExists
            if ($cmdHelp -is [string]) { $cmdHelp = $null }
            $paramBlock = [Management.Automation.Proxycommand]::GetParamBlock($commandExists) -replace '\{(\S{1,})\}', '$1'

            $paramParts = $paramBlock -split ',\W{1,}[\[$]' -ne ''

            $paramBlockParts =
            @(foreach ($param in $paramParts) {
                $lastDollar = $param.LastIndexOf('$')
                $parameterName = $param.Substring($lastDollar + 1).Trim()
                $parameterHelp = if ($cmdHelp) {
                    $cmdHelp.parameters[0].parameter |
                        Where-Object { $_.Name -eq $parameterName -and $_.Description }|
                        Select-Object -ExpandProperty Description |
                        Select-Object -ExpandProperty Text
                } else {
                    $null
                }

                $param = $param.Trim()
                if (-not $param.StartsWith('$') -and -not $param.StartsWith('[')) {
                    $param = "[$param"
                }

                if ($ExcludeParameter) {
                    $shouldExclude =
                        foreach ($ex in $ExcludeParameter) {
                            if ($parameterName -like "$ex") {
                                $true
                                break
                            }
                        }

                    if ($shouldExclude) { continue }
                }

                if ($parameterHelp) {
                    $lines = "$parameterHelp".Split("`r`n",[StringSplitOptions]'RemoveEmptyEntries')
                    if ($lines.Count -lt 8) {
                        (@(foreach ($l in $lines) {
"    #$l"
                        }) -join ([Environment]::NewLine)) +
                        ([Environment]::NewLine) + (' '*4) + $param
                    } else {
"    <#
$parameterHelp
    #>
    $param"
                    }
                } else {
                    $param
                }
            })

            if ($AdditionalParameter) {
                foreach ($kv in $AdditionalParameter.GetEnumerator()) {
                    $varName = if ($kv.Key.StartsWith('$')) { $kv.Key } else { '$' + $kv.Key }

                    $newParamBlockPart =
                    if ($kv.Value -is [type]) {
                        if ($kv.Value.FullName -like "System.*") {
                            "    [$($kv.Value.Fullname.Substring(7))]$varName"
                        } elseif ($kv.Value -eq [switch]) {
                            "    [switch]$varName"
                        } else {
                            "    [$($kv.Value.Fullname)]$varName"
                        }
                    }
                    elseif ($kv.Value -is [string]) {
                        $varDeclared = $false
                        $newLines =
                            foreach ($line in $kv.Value -split [Environment]::NewLine) {
                                $trimLine = $Line.Trim()
                                if ($trimLine.StartsWith('[')) {
                                    if ($trimLine -like $varName) {
                                        $varDeclared = $true
                                    }
                                    (' ' * 4) + $trimLine
                                } # It's an attribute!
                                elseif ($trimLine.StartsWith('$')) { # It's a variable!
                                    $varDeclared = $true
                                    (' ' * 4) + $trimLine
                                }
                                elseif ($trimLine.StartsWith('#'))  { # It's a comment!
                                    (' ' * 4) + $trimLine
                                }
                                else {                                # Otherwise, we'll treat it like a comment anyways
                                    (' ' * 4)  + '#' + $trimLine
                                }
                            }

                        if (-not $varDeclared) {
                            $newLines += (' ' * 4) + $varName
                        }
                        $newLines -join ([Environment]::NewLine)
                    }
                    elseif ($kv.Value -is [Object[]]) {

                    }


                    if ($newParamBlockPart) {
                        $paramBlockParts += $newParamBlockPart
                    }
                }
            }

            $paramBlock = $paramBlockParts -join (',' + ([Environment]::NewLine * 2))


            if (-not $Synopsis) {
                $Synopsis = "Wraps $CommandName"
            }

            if (-not $Description) {
                $Description = "Calls $CommandName, using splatting"
            }

            $exampleText =
                if ($Example) {   
                    @(foreach ($ex in $Example) {
                        "    .Example"
                        foreach ($ln in $ex -split '(?>\r\n|\n)') {
                            "        $ln"
                        }
                    }) -join [Environment]::NewLine
                } else { ''}
            
            $noteText =
                if ($Note) {   
                    @(
                        "    .Notes"
                        foreach ($ln in $Note -split '(?>\r\n|\n)') {
                            "        $ln"
                        }
                    ) -join [Environment]::NewLine
                } else { ''}
             


            $linkText = 
                if ($Link) {
                    @(foreach ($lnk in $Link) {
                    "    .Link"
                    "        $lnk"        
                    }) -join [Environment]::NewLine
                } else { @"
    .Link
        $CommandName
"@
                }
            

[ScriptBlock]::Create("function $FunctionName
{
    <#
    .Synopsis
        $Synopsis
    .Description
        $Description$(
        if ($exampleText) { [Environment]::NewLine + $exampleText}
        )$(
            if ($linkText) { [Environment]::NewLine + $linkText}
        )$(
            if ($NoteText) { [Environment]::NewLine + $noteText}            
        )
    #>$(if ($CmdletBinding) {
        if ($CmdletBinding -like "*CmdletBinding*") {
            [Environment]::NewLine + (' '*4) + $CmdletBinding
        } else {
            [Environment]::NewLine + (' '*4) + "[CmdletBinding($CmdletBinding)]"
        }
        } elseif ($originalCmdletBinding) {
            [Environment]::NewLine + (' '*4) + $originalCmdletBinding
        })$(
        if ($OutputType) {
            [Environment]::NewLine + (' '*4) + '[OutputType(' + @(foreach ($ot in $outputtype) {
                if ($ot -as [type]) {"[$ot]"} else { "'$ot'"}
            }) -join ',' + ')]'
        } else {
            [Environment]::NewLine + (' '*4) + '[OutputType([PSObject])]'
        }
        )
    param(
$paramBlock
    )

    process {
$(@(foreach ($line in $coreSplat -split ([Environment]::Newline)) {
    if ($line.StartsWith("'@")) {
        $line
    } else {
        (' ' * 8) + $line
    }
}) -join ([Environment]::NewLine))
    }
}
")

        } else {
            [ScriptBlock]::Create($coreSplat)
        }

    }
}
