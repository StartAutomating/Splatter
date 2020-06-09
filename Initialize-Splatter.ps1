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
        Initialize-Splatter -Compress > '@.ps1'
    .Example
        Initialize-Splatter -Verb Get > '@.ps1' # Initialize splatter
    #>
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

    # If set, will not minify the definitions
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('NoMinification')]
    [switch]
    $Minify,

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
    $Inline
    )

    begin {
        $CompressScriptBlock = ([ScriptBlock]::Create((
    [IO.StreamReader]::new(([IO.Compression.GZipStream]::new(
        [IO.MemoryStream]::new([Convert]::FromBase64String(@'
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
cXimMTbqP/VR4etMIgAA
'@  )),
    [IO.Compression.CompressionMode]'Decompress')),([Text.Encoding]::unicode))).ReadToEnd()
))

        $myModule = $MyInvocation.MyCommand.ScriptBlock.Module
    }

    process {
        $myParams = @{} + $PSBoundParameters
        $c, $t, $id = 0, $Verb.Count, [Random]::new().Next()
        @(
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

                if ($Minify) {
                    Write-Progress "Minifying" $v -PercentComplete $p -id $id
                    if ($val -isnot [ScriptBlock]) { $val = [ScriptBlock]::Create($val) }
                    "{$(& $CompressScriptBlock $val)}"
                } elseif ($NoHelp) {
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

        if ($Compress) {
            Write-Progress "Compressing" " "  -PercentComplete 99 -id $id
            $data = [Text.Encoding]::Unicode.GetBytes("$($innerContent -join [Environment]::NewLine)")
            $ms = New-Object IO.MemoryStream
            $cs = New-Object System.IO.Compression.GZipStream ($ms, [Io.Compression.CompressionMode]"Compress")
            $cs.Write($Data, 0, $Data.Length)
            $cs.Close()
            $cs.Dispose()
".([ScriptBlock]::Create(([IO.StreamReader]::new((
    [IO.Compression.GZipStream]::new([IO.MemoryStream]::new(
        [Convert]::FromBase64String('
$([Convert]::ToBase64String($ms.ToArray(), 'InsertLineBreaks'))
        ')),
        [IO.Compression.CompressionMode]'Decompress')),
    [Text.Encoding]::unicode)).ReadToEnd()
))"
        } else {

            @(@(if (-not $inline) {'
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="This Declares Variables for Other Scripts")]
param()'
}) + $innerContent) -join [Environment]::NewLine
        }
        if (-not $NoLogo) {
            "#endregion $logo"
        }) -join [Environment]::NewLine
        Write-Progress "Initialized!" " "  -Completed -id $id
    }
}