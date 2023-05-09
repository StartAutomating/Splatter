#require -Module HelpOut
Push-Location ($PSScriptRoot | Split-Path)

$SplatterLoaded = Get-Module Splatter
if (-not $SplatterLoaded) {
    $SplatterLoaded = Get-ChildItem -Recurse -Filter "*.psd1" | Where-Object Name -like 'Splatter*' | Import-Module -Name { $_.FullName } -Force -PassThru
}
if ($SplatterLoaded) {
    "::notice title=ModuleLoaded::Splatter Loaded" | Out-Host
} else {
    "::error:: Splatter not loaded" |Out-Host
}

Save-MarkdownHelp -Module Splatter -SkipCommandType Alias -PassThru

Pop-Location