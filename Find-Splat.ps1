function Find-Splat
{
    <#
    .Synopsis
        Finds commands that can be splatted to given an input.
    .Description
        Finds the commands whose input parameters match an input object, and returns an [ordered] dictionary of parameters.
    .Link
        Get-Splat
    .Link
        Use-Splat
    .Example
        @{Id=$pid} | Find-Splat -Global
    #>
    param(
    # One or more commands.
    # If not provided, commands from the current module will be searched.
    # If there is no current module, all commands will be searched.
    [Parameter(Position=0)]
    [string[]]$Command,

    # The splat
    [Parameter(ValueFromPipeline=$true,Position=1)]
    [Alias('InputObject')]
    [PSObject]$Splat,

    # If set, will look for all commands, even if Find-Splat is used within a module.
    [Alias('G')][switch]$Global,

    # If set, will look for commands within the current module.
    # To make this work within your own module Install-Splat.
    [Alias('L')][switch]$Local,

    # If provided, will look for commands within any number of loaded modules.
    [Alias('M')][string[]]$Module,

    # If set, will return regardless of if parameters map,  are valid, and have enough mandatory parameters
    [switch]$Force)
    begin {
        $myModule = $MyInvocation.MyCommand.ScriptBlock.Module
        $cmdTypes = 'Function,Cmdlet,ExternalScript,Alias'
        $resolveAliases = { begin {
            $n = 0
        } process {
            $n++
            if ($t -and $id) {
                $p = $n* 100 / $t
                Write-Progress "Resolving" "$_ " -PercentComplete $p -Id $id
            }
            if ($_.ResolvedCommand) { $_.ResolvedCommand }
            else { $_ }
        } end {
            Write-Progress 'Resolving Aliases' 'Complete' -Id $id
        } }
        $filterCmds = { process {
            foreach ($c in $Command) { if ($_ -like $c) { return $_ } }
        } }
    }
    process {
        if (-not $Splat) { return }
        $id =[Random]::new().Next()

        $commandList =
            @(if (-not $Command) {
                Write-Progress -Id $id -Activity 'Getting Commands' -Status ' '
                if ($MyModule -and $Local) {
                    $myModule.ExportedCommands.Values | . $resolveAliases | Select-Object -Unique
                } elseif ($module) {
                    foreach ($m in $Module) {
                        $rm = Get-Module $m
                        if (-not $rm) { continue }
                        $rm.ExportedCommands.Values | . $resolveAliases | Select-Object -Unique
                    }
                } else {
                    $allcmds = @($ExecutionContext.SessionState.InvokeCommand.GetCommands('*',$cmdTypes, $true))
                    $t = $allcmds.Count
                    $allcmds |. $resolveAliases | Select-Object -Unique
                }
            } elseif ($module) {
                foreach ($m in $Module) {
                    $rm = Get-Module $m
                    if (-not $rm) { continue }
                    $rm.ExportedCommands.Values |
                        . $resolveAliases | . $filterCmds |
                        Select-Object -Unique
                }
            } elseif ($Global) {
                foreach ($c in $Command) {
                    $ExecutionContext.SessionState.InvokeCommand.GetCommands($c,$cmdTypes, $true)
                }
            } elseif ($MyModule -and $Local) {
                $myModule.ExportedCommands.Values |
                        . $filterCmds | . $resolveAliases | Select-Object -Unique
            } else {
                foreach ($cmd in $Command) {
                    if ($cmd -is [string] -and $cmd.Contains('*')) {
                        $ExecutionContext.SessionState.InvokeCommand.GetCommands($cmd,$cmdTypes, $true)
                    } else {
                        $cmd
                    }
                }
            })
        $psBoundParameters.Command = $commandList
        if ($Splat -is [Collections.IDictionary]) {
            $Splat =
                if ($splat.GetType().Name -ne 'PSBoundParametersDictionary') {
                    [PSCustomObject]$Splat
                } else {
                    [PSCustomObject]([Ordered]@{} +  $Splat)
                }
        }

        $c,$t=  0, $commandList.Count
        foreach ($cmd in $commandList) {
            if ($t -gt 1) {
                $c++;$p=$c*100/$t
                Write-Progress -Id $id -Activity 'Finding Splats' -Status "$cmd " -PercentComplete $p
            }
            $Splat |
                & ${?@} $cmd -Force:$Force |
                Select-Object -Property * -ExcludeProperty SyncRoot,IsSynchronized,IsReadOnly,IsFixedSize,Count |
                & { process {
                    if ($_.PercentFit -eq 0) { return }
                    $_.pstypenames.clear()
                    $_.pstypenames.add('Find.Splat.Output')
                    $keys, $values = @($_.Keys), @($_.Values)
                    $resplat = [Ordered]@{}
                    for ($i=0;$i -lt $keys.count;$i++) {
                        $resplat[$keys[$i]] = $values[$i]
                    }
                    $_.psobject.properties.remove('Keys')
                    $_.psobject.properties.remove('Values')
                    $_.psobject.properties.Add([Management.Automation.PSNoteProperty]::new('Splat', $resplat))
                    $_
                } }
        }

        Write-Progress -Id $id -Completed -Activity 'Finding Splats' -Status 'Complete!'
    }
}