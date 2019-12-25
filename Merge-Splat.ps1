function Merge-Splat
{
    <#
    .Synopsis
        Merges one or more splats
    .Description
        Merges one or more hashtables and property bags into one [ordered] hashtable.
        Allows you to -Remove specific keys from any object
        Allows you to -Include or -Exclude wildcards of keys (or patterns, with -RegularExpression)
        Allows you to -Map additional values if a value if found.
    .Link
        Get-Splat
    .Link
        Use-Splat
    .Example
        @{a='b'}, @{c='d'} | Merge-Splat
    .Example
        [PSCustomOBject]@{a='b'}, @{c='d'} | Merge-Splat -Add @{e='f'} -Remove c
    .Example
        @{id=$pid} |
            Use-Splat Get-Process |
            Merge-Splat -Include Name
    .Example
        @{n=$(Get-Random) } |
            Merge-Splat -Map @{
                N = {
                    if (-not ($_ % 2)) { @{IsEven=$true;IsOdd=$false} }
                    else { @{IsEven=$false;IsOdd=$true}}
                }
            }
    #>
    param(
    # The splat
    [Parameter(ValueFromPipeline=$true)]
    [Alias('InputObject')]
    [PSObject[]]
    $Splat,

    # Splats or objects that will be added to the splat.
    [Parameter(Position=0,ValueFromRemainingArguments=$true)]
    [Alias('With', 'W', 'A', '+')]
    [PSObject[]]
    $Add,

    # The names of the keys to remove from the splat
    [Alias('Delete','Drop', 'D','R', '-')]
    [string[]]
    $Remove,

    # Patterns of names to include in the splat.
    # If provided, only keys that match at least one -Include pattern will be kept.
    # By default, these are wildcards, unlesss -RegularExpression is passed.
    [Alias('E', 'EX')]
    [string[]]
    $Include,

    # Patterns of names to exclude from the splat.
    # By default, these are wildcards, unlesss -RegularExpression is passed.
    [Alias('I', 'IN')]
    [string[]]
    $Exclude,

    # If set, all patterns matched will be assumed to be RegularExpressions, not wildcards
    [Alias('Regex','RX')]
    [switch]
    $RegularExpression,

    # A map of new data to add.  The key is the name of the original property.
    # The value can be any a string, a hashtable, or a script block.
    # If the value is a string, it will be treated as a key, and the original property will be copied to this key.
    # If the value is a hashtable, it will add the values contained in Map.
    # If the value is a ScriptBlock, it will combine the output of this script block with the splat.
    [Alias('M','ReMap')]
    [Collections.IDictionary]
    $Map,

    [switch]
    $Keep,

    [switch]
    $Replace)


    begin {
        $accumulate = [Collections.ArrayList]::new()
        $aSplat = {param($o, $i)
            if ($i -is [Collections.IDictionary]) {
                try { $o += $i }
                catch {
                    foreach ($kv in $i.GetEnumerator()) {
                        $gotIt? = $o.Contains($kv.Key)
                        if ($gotIt? -and $Keep) { continue }
                        if ($gotIt? -and $Replace) {
                            $o[$kv.Key] = $kv.Value;continue
                        } elseif ($gotIt?) {
                            if ($o[$kv.Key] -isnot [Object[]]) {
                                $o[$kv.Key] = @($o[$kv.Key])
                            }
                            $o[$kv.Key] += $kv.Value
                        } else {
                            $o[$kv.Key] = $kv.Value
                        }
                    }

                }
            } else {
                foreach ($prop in $i.psobject.properties) { $o[$prop.Name] = $prop.Value }
            }
        }
        $imSplat = {
            if (-not $accumulate.Count) { return }
            $o = [Ordered]@{}
            foreach ($in in $accumulate) {
                . $aSplat $o $in
            }
            $ok = @($o.Keys)
            :nextKey foreach ($k in $ok) {
                if ($Map -and $map.$k) {
                    foreach ($mk in $map.$k) {
                        if ($mk -is [string]) { $o[$mk] = $o[$k] }
                        elseif ($mk -is [Collections.IDictionary]) {
                            . $aSplat $o $mk
                        }
                        elseif ($mk -is [ScriptBlock]) {
                            $_ = $o[$k]
                            $mkr = . $mk $_
                            foreach ($r in $mkr) { . $aSplat $o $r }
                        }
                    }
                }

                if ($Exclude) {
                    foreach ($ex in $Exclude) {
                        if (($RegularExpression -and ($k -match $ex)) -or
                            ($k -like $ex)) {
                            $o.Remove($k)
                            continue nextKey
                        }
                    }
                }

                if ($include) {
                    foreach ($in in $include) {
                        if (($RegularExpression -and ($k -match $in)) -or
                            ($k -like $in)) {
                            continue nextKey
                        }
                    }
                    $o.Remove($k)
                }
            }
            foreach ($r in $Remove) { $o.Remove($r) }
            $accumulate.Clear()
            $o
        }
    }
    process {
        $isTheEndOfTheLine? =
            $MyInvocation.PipelinePosition -eq $MyInvocation.PipelineLength
        if ($Splat) { $accumulate.AddRange($Splat) }
        if ($Add) { $accumulate.AddRange($add) }
        if (-not $isTheEndOfTheLine?) {
            . $imSplat
        }
    }

    end {
        . $imSplat
    }
}
