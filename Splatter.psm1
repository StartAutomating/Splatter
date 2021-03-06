[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="This exports variables")]
param()
. $psScriptRoot\Find-Splat.ps1
. $psScriptRoot\Get-Splat.ps1
. $psScriptRoot\Merge-Splat.ps1
. $psScriptRoot\Out-Splat.ps1
. $psScriptRoot\Use-Splat.ps1

. $psScriptRoot\Initialize-Splatter.ps1

# ?@ Get the splat for a given command.
Set-Alias -Name '?@' -Value Get-Splat
Set-Alias -Name 'gSplat' -Value Get-Splat
Set-Alias -Name '??@' -Value Find-Splat
Set-Alias -Name 'fSplat' -Value Find-Splat
Set-Alias -Name '.@' -Value Use-Splat
Set-Alias -Name 'uSplat' -Value Use-Splat
Set-Alias -Name '*@' -Value Merge-Splat
Set-Alias -Name 'mSplat' -Value Merge-Splat
Set-Alias -Name '=>@' -Value Out-Splat

${?@} = $gSplat = $GetSplat = ${function:Get-Splat}
${??@} = $fSplat = $FindSplat = ${function:Find-Splat}
${*@} = $mSplat = $MergeSplat = ${function:Merge-Splat}
${.@} = $uSplat = $UseSplat = ${function:Use-Splat}

Export-ModuleMember -Alias * -Function * -Variable *