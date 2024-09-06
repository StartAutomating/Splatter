#requires -Module PSDevOps
#requires -Module Splatter
Import-BuildStep -SourcePath (
    $psScriptRoot | Join-Path -ChildPath "GitHub"
) -BuildSystem GitHubAction
Push-Location ($PSScriptRoot | Split-Path)
New-GitHubAction -Name "UseSplatter" -Description @'
Simple Scripts to Supercharge Splatting
'@ -Action SplatterAction -Icon at-sign -OutputPath .\action.yml
Pop-Location