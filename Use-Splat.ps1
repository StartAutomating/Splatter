function Use-Splat
{
    <#
    .Synopsis
        Uses a splat.
    .Description
        Uses a splat to call a command.
        If passed from Find-Splat,Get-Splat or Test-Splat, the command will be automatically detected.
        If called as .@, this will run only provided commands
        If called as *@, this will run any found commands
    .Link
        Get-Splat
    .Link
        Find-Splat
    .Link
        Test-Splat
    .Example
        @{id=$pid} | Use-Splat gps # When calling Use-Splat is globally imported
    .Example
        @{id=$pid} | & ${.@} gps # When calling Use-Splat is nested
    .Example
        @{LogName='System';InstanceId=43,44},
        @{LogName='Application';InstanceId=10000,10005} |
            .@ Get-EventLog # get a bunch of different log events
    #>
    param(
    # One or more commands
    [Parameter(Position=0)]
    [PSObject[]]
    $Command,

    # Any additional positional arguments that would be passed to the command
    [Parameter(Position=1,ValueFromRemainingArguments=$true)]
    [PSObject[]]
    $ArgumentList = @(),

    # The splat
    [Parameter(ValueFromPipeline=$true)]
    [PSObject[]]
    $Splat,

    # If set, will run regardless of if parameters map, are valid, and have enough mandatory parameters.
    [switch]
    $Force,
    
    # If set, will stream input into a single pipeline of each command.
    # The non-pipeable parameters of the first input splat will be used to start the pipeline.     
    # By default, a command will be run once per input splat.   
    [Alias('Pipe')]
    [switch]
    $Stream)

    begin {
        $pipelines = @{}
    }
    process {
        $WeTrustTheSplat = $false
        if (-not $Command -and
            $splat.Length -eq 1 -and
            $splat[0] -is [Collections.IDictionary] -and
            $Splat[0].psobject.Properties['Command']) {
            $Command = $Splat[0].psobject.Properties['Command'].Value
            $WeTrustTheSplat = $true
        } elseif (-not $command -and $_ -is [PSObject] -and $_.Command -and $_.Splat) {
            $WeTrustTheSplat = $true
            $splat = $_.Splat
            $command = $_.Command
        }

        if (-not $Command) {
            Write-Error -Message "No command found" -Category ObjectNotFound -ErrorId 'Use-Splat.CommandNotFound' ;return
        }
        #region UseTheSplat
        foreach ($cmd in $Command) {
            if ($WeTrustTheSplat) {
                if ($cmd -is [Management.Automation.CommandInfo] -or $cmd -is [ScriptBlock]) {
                    foreach ($s in $splat) {
                        if ($argumentList) {
                            & $cmd @s @ArgumentList
                        } else {
                            & $cmd @s
                        }
                    }
                }
            } else {
                $Splat |
                    & ${?@} $cmd -Force:$Force |
                    & { process {
                        
                        $i = $_
                        $np = $i.NonPipelineParameter
                        $c = $_.psobject.properties['Command'].Value
                        if ($Stream) {
                            if (-not $pipelines[$c]) {
                                
                                $stepScript = if ($argumentList) { {& $c @np @argumentList} } else { {& $c @np} }
                                
                                $stepPipeline = $stepScript.GetSteppablePipeline()
                                $pipelines[$c] = $stepPipeline
                                $stepPipeline.Begin($true)
                            } else {
                                $stepPipeline = $pipelines[$c]
                            }
                            $stepPipeline.Process([PSCustomObject]$i.PipelineParameter)
                            return
                        }

                        if ($c -is [Management.Automation.CommandInfo] -or $c -is [ScriptBlock]) {
                            if ($ArgumentList) {
                                & $c @i @ArgumentList
                            } else {
                                & $c @i
                            }
                        }
                    }}
            }
        }
        #endregion UseTheSplat
    }

    end {
        if ($pipelines.Count) {
            foreach ($v in $pipelines.Values) { $v.End() }
        }
    }
}