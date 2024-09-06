$commandsPath = Join-Path $PSScriptRoot .\Commands
[include('*-*')]$commandsPath

$myModule = $MyInvocation.MyCommand.ScriptBlock.Module
$ExecutionContext.SessionState.PSVariable.Set($myModule.Name, $myModule)
$myModule.pstypenames.insert(0, $myModule.Name)

New-PSDrive -Name $MyModule.Name -PSProvider FileSystem -Scope Global -Root $PSScriptRoot -ErrorAction Ignore

if ($home) {
    $MyModuleProfileDirectory = Join-Path $home $MyModule.Name
    if (-not (Test-Path $MyModuleProfileDirectory)) {
        $null = New-Item -ItemType Directory -Path $MyModuleProfileDirectory -Force
    }
    New-PSDrive -Name "My$($MyModule.Name)" -PSProvider FileSystem -Scope Global -Root $MyModuleProfileDirectory -ErrorAction Ignore
}

$KnownVerbs = Get-Verb | Select-Object -ExpandProperty Verb

# Set a script variable of this, set to the module
# (so all scripts in this scope default to the correct `$this`)
$script:this = $myModule

$myScriptTypeCommands = foreach ($myScriptType in $myModule.Name) {
    $myTypeData = Get-TypeData $myScriptType
    if (-not $myTypeData.Members) { continue } 
    foreach ($myMemberInfo in $myTypeData.Members.GetEnumerator()) {
        $myMemberName = $myMemberInfo.Key
        $myMember = $myMemberInfo.Value
        if ($myMember -is [Management.Automation.Runspaces.ScriptMethodData]) {            
            $myFunctionName = 
                if ($myMemberName -in $KnownVerbs) {
                    "$($myMemberName)-$($myScriptType)"
                } else {
                    "$($myScriptType).$($myMemberName)"
                }
            # Declare My Function
            "function $myFunctionName { $($myMember.Script) }"
            if ($myMemberName -in $KnownVerbs) {
                # Alias it if it's a known verb, so both verb and noun form are available.
                "Set-Alias -Name '$($myScriptType).$($myMemberName)' -Value '$myFunctionName'"            
            }
            
            "Set-Alias -Name '$($myMemberName).$($myScriptType)' -Value '$myFunctionName'"
        }
    }        
}

. ([ScriptBlock]::Create($myScriptTypeCommands -join [Environment]::NewLine))

Export-ModuleMember -Alias * -Function * -Variable $myModule.Name