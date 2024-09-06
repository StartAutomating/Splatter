#requires -Module PSDevOps
Import-BuildStep -SourcePath (
    $psScriptRoot | Join-Path -ChildPath "GitHub"
) -BuildSystem GitHubWorkflow
Push-Location ($PSScriptRoot | Split-Path)
New-GitHubWorkflow -Name "Analyze, Test, Tag, and Publish" -On Push, PullRequest, Demand -Job PowerShellStaticAnalysis,
    TestPowerShellOnLinux,
    TagReleaseAndPublish,
    BuildSplatter -OutputPath .\.github\workflows\TestBuildAndPublish.yml
Pop-Location