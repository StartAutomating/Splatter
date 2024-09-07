@{
    CompanyName = 'Start-Automating'
    Copyright = '2019-2024 Start-Automating'
    RootModule = 'Splatter.psm1'
    Description = 'Simple Scripts to Supercharge Splatting'
    ModuleVersion = '0.5.5'
    AliasesToExport = '*'
    VariablesToExport = '*'
    GUID = '033f35ed-f8a7-4911-bb62-2691f505ed43'
    Author = 'James Brundage'
    PrivateData = @{
        PSData = @{
            ProjectURI = 'https://github.com/StartAutomating/Splatter'
            LicenseURI = 'https://github.com/StartAutomating/Splatter/blob/master/LICENSE'
            IconURI    = 'https://raw.githubusercontent.com/StartAutomating/Splatter/master/Assets/Splatter.png'
            Tags = 'Splatting', 'PipeScript'
            CommandTypes = @{
                
            }
            ReleaseNotes = @'
### 0.5.5:

* Splatter is now a GitHub Action! (#18)
* Initialize-Splatter now returns a `[ScriptBlock]` (#21)
* Initialize-Splatter/Out-Splat now have -OutputPath (#19/#20)
* Added Sponsorship (#22)
'@
        }
    }
}
