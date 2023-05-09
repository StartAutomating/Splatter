@{
    CompanyName = 'Start-Automating'
    Copyright = '2019-2021 Start-Automating'
    RootModule = 'Splatter.psm1'
    Description = 'Simple Scripts to Supercharge Splatting'
    ModuleVersion = '0.5.4'
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
            ReleaseNotes = @'
### 0.5.4:

* New Splatter Logo (#12)
* All splats will become PSObjects consistently (#13)
* Generated Documentation (#14)
* Declaring aliases inline (#16)

---

### 0.5.3:
* Out-Splat now supports -Examples, -Links, -Notes, and -OutputTypes (Issue #9)
* Adding logo
* Documentation updates.

### 0.5.2:
* Improved pipeline support (Fixes #6)
* Out-Splat -CrossStream will now output all streams in generated commands, not just error and output.
'@
        }
    }
}
