function Out-Splatter
{
    <#
    .Synopsis
        Outputs code that splats
    .Description
        Outputs a function or script that primarily calls another command.  This can get messy to write by hand.
    .Link
        Initialize-Splatter
    #>
    [CmdletBinding(DefaultParameterSetName='JustTheSplatter')]
    param(
    # The name of the command that will be splatted
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
    [Alias('Name')]
    [string]
    $CommandName,

    # A hashtable of default parameters.  These will always be passed to the underlying command by name.
    [Parameter(Position=1,ValueFromPipelineByPropertyName=$true)]
    [Alias('DefaultParameters')]
    [Hashtable]
    $DefaultParameter = @{},

    # A list of arguments.  These will be always be passed to the underlying commands by position.
    # Items starting with $ will be treated as a variable.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string[]]
    $ArgumentList,

    # An optional name of a generated function.  
    # If provided, this function will declare any input parameters specified in -InputParameter 
    [Parameter(Mandatory=$true,Position=2,ValueFromPipelineByPropertyName=$true,ParameterSetName='FunctionalSplatter')]
    [string]
    $FunctionName,

    # A list of parameters names that will be inputted from the original command into the splat. 
    # If generating a function, these parameter declarations will be copied from the underlying command.
    # Help for these parameters will be included as comment-based help
    [Parameter(Position=3,ValueFromPipelineByPropertyName=$true)]
    [Alias('IncludeParameter')]
    [string[]]
    $InputParameter,

    # A list of parameters that will be excluded from the original function.
    # This is only valid when generating a function.
    # Wildcards may be used.
    [Parameter(Position=4,ValueFromPipelineByPropertyName=$true)]
    [string[]]
    $ExcludeParameter,

    # If set, values from input parameters will override default values.
    [Alias('OverrideDefault','OverwriteDefault', 'DefaultOverwrite')]
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Switch]
    $DefaultOverride,

    # If set, any variable with a non-null value matching the input parameters will be used to splat.
    # If not set, only bound parameters will be used to splat.
    # If no function name is provided, this will automatically be set
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Switch]
    $VariableInput,

    # The name of the variable used to hold the splatted parameters.  By default, splat
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $SplatName = 'splat',

    # The synopsis.  
    # This is used to make comment-based help in a generated function.  
    # By default, it is : "Wraps $CommandName"
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='FunctionalSplatter')]
    [string]
    $Synopsis,

    # The description.
    # This is used to make comment-based help in a generated function.
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='FunctionalSplatter')]
    [string]
    $Description,

    # The CmdletBinding attribute for a new function
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='FunctionalSplatter')]
    [string]
    $CmdletBinding,

    # The serialization depth for default parameters.  By default, 2. 
    [uint32]
    $SerializationDepth = 2,

    # If set, will cross errors into the output stream.  
    # You SHOULD cross the streams when dealing with console applications, as many of them like to return output on standard error.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
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
    $PipeTo,

    # A set of additional parameter declarations.  The keys are the names of the parameters, and the values can be a type and a string containing parameter binding and inline help.
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='FunctionalSplatter')]
    [Hashtable]
    $AdditionalParameter)

    process {
        $MyParameters = @{} + $PSBoundParameters
        $commandExists = $ExecutionContext.SessionState.InvokeCommand.GetCommand($CommandName, 'All')

        if (-not $commandExists) {
            Write-Error "$CommandName does not exist"
            return
        }
        $defaultDeclaration = 
            if ($DefaultParameter.Count) {
                $toSplat = "@'
$(ConvertTo-Json $DefaultParameter -Depth $SerializationDepth)
'@"
                "`$${splatName}Default = ConvertFrom-Json $toSplat"
                "`$$splatName = @{}"
                "foreach (`$property in `$${splatName}Default.psobject.properties) {
`$$SplatName[`$property.Name] = `$property.Value
if (`$property.Value -is [string] -and `$property.Value.StartsWith('`$')) {
    `$$SplatName[`$property.Name] = `$executionContext.SessionState.PSVariable.Get(`$property.Value.Substring(1)).Value    
}
}"
            } elseif ($ArgumentList.Count) {
                "`$$splatName = " + @(foreach ($a in $ArgumentList) {
                    if ($a.StartsWith('$')) {
                        $a
                    } else {
                        "'$($a.Replace("'","''"))'"
                    }
                }) -join ','
            } else {
                "`$$splatName = @{}"
            }

        if ($InputParameter.Count -eq 1 -and $InputParameter -eq '*') {            
            if ($commandExists -is [Management.Automation.ApplicationInfo]) {
                $InputParameter = @()    
            } else {
                $InputParameter = ($commandExists -as [Management.Automation.CommandMetaData]).Parameters.Keys
            }
        }

        if (-not $FunctionName) { $VariableInput = $true } 

        $paramSplat = 
        if ($InputParameter) {            
            if ($VariableInput) {
"
#region Copy Parameters from $CommandName
foreach (`$in in '$($inputParameter -join "','")') {
    `$var = `$executionContext.SessionState.PSVariable.Get(`$in)
    if (-not `$var) { continue } 
    $(if ($DefaultOverride) {
    "`$$splatName.`$in = `$var.Value"
    } else {
    "`$$splatName.`$in = `$var.Value"
    })
}
#endregion Copy Parameters from $CommandName
"
            } else {
                "#region Copy Parameters from $CommandName
`$MyParameters = @{} + `$psBoundParameters # Copy `$PSBoundParameters
foreach (`$in in '$($inputParameter -join "','")') {
    $(if ($DefaultOverride) {
    "if (`$myParameters.`$in) {
        `$$splatName.`$in = `$myParameters.`$in
    }"
    } else {
    "if (-not `$$splatName.`$in -and `$myParameters.`$in) {
        `$$splatName.`$in = `$myParameters.`$in
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
                " & '$($commandExists.Source.Replace("'","''"))' @$splatName"
            } else {
                "$commandExists @$splatName"
            }

        if ($CrossStream) {
            $cmdDef += " 2>&1"
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
 
"function $FunctionName
{
    <#
    .Synopsis
        $Synopsis
    .Description
        $Description
    .Link
        $CommandName
    #>$(if ($CmdletBinding) { 
        if ($CmdletBinding -like "*CmdletBinding*") {
            [Environment]::NewLine + (' '*4) + $CmdletBinding
        } else {
            [Environment]::NewLine + (' '*4) + "[CmdletBinding($CmdletBinding)]"
        }
        } elseif ($originalCmdletBinding) {
            [Environment]::NewLine + (' '*4) + $originalCmdletBinding
        })
    param(
$paramBlock)
    
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
"
            
            #[Management.Automation.Proxycommand]::GetHelpComments($cmdHelp)
            
        } else {
            $coreSplat
        }

    }
} 
