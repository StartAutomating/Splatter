[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="This exports variables")]
param()
. $psScriptRoot\Find-Splat.ps1
. $psScriptRoot\Get-Splat.ps1
. $psScriptRoot\Merge-Splat.ps1
. $psScriptRoot\Out-Splat.ps1
. $psScriptRoot\Use-Splat.ps1

. $psScriptRoot\Initialize-Splatter.ps1

# Assign each splatter command to a variable for easy internal access
${?@} = $gSplat = $GetSplat = ${function:Get-Splat}
${??@} = $fSplat = $FindSplat = ${function:Find-Splat}
${*@} = $mSplat = $MergeSplat = ${function:Merge-Splat}
${.@} = $uSplat = $UseSplat = ${function:Use-Splat}
${=>@} = $uSplat = $OutSplat = ${function:Out-Splat}

Export-ModuleMember -Alias * -Function * -Variable *
