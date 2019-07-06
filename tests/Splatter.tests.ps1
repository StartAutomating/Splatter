describe Splatter {
    it 'Can Find Matching Parameters for a Command' {
        $splatOut = @{id = $pid;Foo='bar'} | Get-Splat -Command Get-Process
        $splatOut.Keys.Count | should be 1
    }
    it 'Can remove invalid input' { 
        @{id = $pid;Timeout=65kb} | 
            Get-Splat -Command Wait-Process | 
            Select-Object -ExpandProperty Count | 
            should be 1
    }
    it 'Can be used to pipe to a splat' {
        @{id=$pid } | Use-Splat -Command Get-Process
    }
    it 'Can accept objects, and turn them into hashtables' {
        New-Object PSObject -Property @{
            Id = $PID
        } | 
            Use-Splat -Command Get-Process
    }
    it 'Can handle parameter aliases' {
        @{Pid = $PID}  | Get-Splat -Command Get-Process
    }
    it 'Can find commands that fit a splat' {
        @{Id=$Pid } | Find-Splat -Command *-Process -Global
    }
    it 'Has a fun alias for Get-Splat: ?@' {
        @{id=$pid } | ?@ -Command Get-Process
    }
    
    it 'Has a fun alias for Use-Splat: .@' {
        @{id=$pid} | .@ gps
    }

    it 'Can splat a script block' {
        $splat =@{Message='hi'}
        $splat | .@ {
            param([Parameter(Mandatory=$true)][string]$Message) $Message 
        } | should be hi 
    }
}
