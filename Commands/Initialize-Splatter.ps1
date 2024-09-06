function Initialize-Splatter
{
    <#
    .Synopsis
        Initializes an embeddable version of Splatter
    .Description
        Initialize-Splatter enables you to embed Splatter into any module.
    .Link
        Get-Splat
    .Link
        Find-Splat
    .Link
        Use-Splat
    .Link
        Merge-Splat
    .Example
        Initialize-Splatter > '@.ps1' # Initialize Splatter            
    .Example
        Initialize-Splatter -Verb Get > '@.ps1' # Initialize splatter
    #>
    [Alias('Include-Splatter','Inline-Splatter')]
    param(
    # The verbs to install.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateSet('Get','Use','Find','Merge','Out')]
    [string[]]
    $Verb = @('Get','Find','Merge','Use'),

    # If set, will not compress the definitions
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('NoCompression')]
    [switch]
    $Compress,    

    # If set, will not add a line of documentation linking to the module
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [switch]
    $NoLogo,

    # If set, will strip inline help from the commands.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [switch]
    $NoHelp,

    # If set, will define the commands as functions and define aliases.
    # If you use this, please use the manifest or Export-ModuleMember to hide Splatter's commands.
    # If not set, Splatter will install as ScriptBlocks (these will not be exported from a module)
    [switch]
    $AsFunction,

    # If set, splatter will be defined inline.
    # This will not preface Splatter with a param() block and PSScriptAnalyzer suppression messages
    [switch]
    $Inline,

    # The output path.
    # If provided, will output to this file and return the file.
    [string]
    $OutputPath
    )

    begin {
        $myModule = $MyInvocation.MyCommand.ScriptBlock.Module
    }

    process {
        $myParams = @{} + $PSBoundParameters
        $c, $t, $id = 0, $Verb.Count, [Random]::new().Next()
        $SplatterScript = @(
        if (-not $NoLogo) {
            $logo = @(
                $myModule.Name
                '['
                $myModule.Version
                ']'
                ':'
                $myModule.Description
                "(Install-Module $($myModule.Name), then $($MyInvocation.MyCommand.Name)"
                $(if ($myParams.Verb) {"-Verb $($verb -join ',')"})
                @(foreach ($kv in $myParams.GetEnumerator()) {
                    if ($kv.Value -is [switch] -and $kv.Value) {
                        "-$($kv.Key)"
                    }
                }) | Sort-Object
                ')'
            ) -join ' '
            "#region $logo"
        }
        if ($verb -notcontains 'Get') {
            $verb += 'Get'
        }

        $innerContent = foreach ($v in $Verb) {
            $var = $ExecutionContext.SessionState.PSVariable.Get("${v}Splat")
            if ($var.Value -isnot [ScriptBlock]) { continue }
            $c++
            $p = $c * 100 / $t
            Write-Progress "Preparing" $v -PercentComplete $p -id $id
            @(
                $myModule.ExportedVariables.Values |
                            & { process {
                    if ($_.Value -eq $var.Value){ "`${$($_.Name)}"}
                } }
                $val = $var.Value

                if ($AsFunction) {
                    "`${function:$v-Splat}"
                }

                if ($NoHelp) {
                    "{$($val -replace '\<\#(?<Block>(.|\s)+?(?=\#>))\#\>', '')}"
                } else {
                    "{$val}"
                }
            ) -join '='

            if ($AsFunction) {
                foreach ($a in $myModule.ExportedAliases.Values) {
                    if ($a.ResolvedCommand.Name -eq "$v-Splat") {
                        "Set-Alias '$a' '$v-Splat'"
                    }
                }
            }
        }
        
        @(@(if (-not $inline) {'
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="This Declares Variables for Other Scripts")]
param()'
}) + $innerContent) -join [Environment]::NewLine
        
        if (-not $NoLogo) {
            "#endregion $logo"
        }) -join [Environment]::NewLine

        if ($outputPath) {
            if (-not (Test-Path $outputPath)) {
                $null = New-Item -ItemType File -Path $outputPath -Force
            }
            "$SplatterScript" | Set-Content -Path $outputPath
            Get-Item -Path $outputPath
        } else {
            try {
                [ScriptBlock]::Create($SplatterScript)
            } catch {
                Write-Debug "$($_ | Out-String)"
                $SplatterScript
            }
        }

        Write-Progress "Initialized!" " "  -Completed -id $id
    }
}