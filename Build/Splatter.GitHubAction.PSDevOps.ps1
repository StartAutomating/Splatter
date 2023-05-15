#requires -Module PSDevOps
#requires -Module Splatter
Import-BuildStep -ModuleName Splatter
Push-Location ($PSScriptRoot | Split-Path)
New-GitHubAction -Name "UseSplatter" -Description @'
Simple Scripts to Supercharge Splatting
'@ -Action SplatterAction -Icon at-sign -OutputPath .\action.yml
Pop-Location