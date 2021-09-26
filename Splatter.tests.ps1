#requires -Module Pester, Splatter

describe Splatter {
    context 'Get-Splat makes splatting more gettable' {
        it 'Will Find Matching Parameters for a Command' {
            $splatOut = @{id = $pid;Foo='bar'} | Get-Splat -Command Get-Process
            $splatOut.Keys.Count | should be 1
        }
        it 'Will remove invalid input' {
            @{id = $pid;Timeout=65kb} |
                Get-Splat -Command Wait-Process |
                Select-Object -ExpandProperty Count |
                should be 1

            @{id="blah"} | Get-Splat -Command Get-Process
        }
        it 'Will make strings into ScriptBlocks, if it has to' {
            @{ScriptBlock = "'Hello World'"} | Get-Splat Invoke-Command
        }
        it 'Will let you pipe splats' {
            @{id=$pid } | Use-Splat -Command Get-Process
        }
        it 'Will accept objects, and turn them into hashtables' {
            New-Object PSObject -Property @{
                Id = $PID
            } |
                Use-Splat -Command Get-Process
        }
        it 'Will handle parameter aliases' {
            @{Pid = $PID}  | Get-Splat -Command Get-Process
        }
        it 'Will handle piped input' {
            Get-Process -Id $pid |
                Get-Splat -Command Get-Process |
                    Use-Splat Get-Process |
                        Select-Object -ExpandProperty ID |
                            Should -Be $pid
        }
        it 'Can see if you can pass down $psBoundParameters' {
            function foo([int]$id,[string]$Message) {
                $foundSplat = $PSBoundParameters | Get-Splat get-process
                $foundSplat | Use-Splat
            }

            (foo -id $pid).id|
                should be $pid
        }
    }



    it 'Will find commands that fit a splat' {
        @{pid=$Pid } | Find-Splat -Command *-Process -Global
    }

    context 'Splatter Aliases are Sweet Syntax Sugar' {
        it '?@ gets a splat' {
            @{id=$pid } | Get-Splat -Command Get-Process
        }

        it '??@ finds a splat' {
            @{splat=@{}} | Find-Splat -Local
        }

        it '*@ merges splats' {
            @{a='b'}|
                Merge-Splat -Add @{c='d'} |
                Select-Object -ExpandProperty Keys | should be a,c
        }

        it '.@ (Use-Splat)' {
            @{id=$pid} | Use-Splat gps
        }
    }



    context 'Simplified splatting to script blocks' {
        it 'Is easy to splat a script block' {
            $splat =@{Message='hi'}
            $splat | Use-Splat {
                param([Parameter(Mandatory=$true)][string]$Message) $Message
            } | should be hi
        }

        it 'Can find matching scripts for a piece of data' {
            $Fruit, $vegetable = {
                param(
                [Parameter(Mandatory=$true)]
                [string]$Name,
                [Parameter(Mandatory=$true)]
                [ValidateSet('Fruit')]
                [string]$Type
                )
                "$Name is a $type"
            }, {
                param(
                [Parameter(Mandatory=$true)]
                [string]$Name,
                [Parameter(Mandatory=$true)]
                [ValidateSet('Vegetable')]
                [string]$Type
                )
                "$Name is a $type"
            }

            $matchedSplat = @{name='apricot';type='fruit'} |
                Get-Splat $Fruit,$vegetable
            $matchedSplat |
                Select-Object -ExpandProperty Command |
                should be $Fruit

            $matchedSplat | Use-Splat | should be 'apricot is a fruit'
        }

        it 'Can pass additional arguments' {
            $2Splat = @{}  | Get-Splat {$args}
            $123 = $2Splat | Use-Splat -ArgumentList 1,2,3
            $Another123 = @{} | Use-Splat {$args} 1 2 3
            $123 | should be 1,2,3
            $Another123 | should be 1,2,3
        }
    }

    context 'Squishing Splats together with Merge-Splat' {
        it 'Is easy to combine N hashtables and objects into one with Merge-Splat' {
            @{a='b'}|
                Merge-Splat -Add @{c='d'} |
                Select-Object -ExpandProperty Keys |
                should be a,c

        }
        it 'Is easy to remove keys from a Splat' {
            @{a='b';c='d';e='f'} |
                Merge-Splat -Remove c |
                Select-Object -ExpandProperty Keys
        }

        it 'Can -Map new keys, if a key was found' {
            @{a='b'} | Merge-Splat -Map @{a='b',@{c='d'},{@{e='f'}}} |
            Select-Object -ExpandProperty Keys |
            Sort-Object |
            should be a,b,c,e
        }

        it 'Can -Map back objects,if a key was found' {
            @{id=$Pid} | Merge-Splat -Map @{id={
                Get-Process -id $args
            }}
        }

        it 'Can -Exclude keys' {
            @{a='b';"c$(Get-Random)"='d'} |
                Merge-Splat -Exclude c* |
                Select-Object -ExpandProperty Keys |
                should be a
        }

        it 'Can -Include Keys' {
            @{a='b';"c$(Get-Random)"='d'} |
                Merge-Splat -Include c* |
                Select-Object -ExpandProperty Keys |
                should belike c*
        }

        it 'Will squish collisions' {
            $merged = @{a='b'},[Ordered]@{a='a';b='b';c='c'} | Merge-Splat
            $merged.keys | should be a,b,c
            $merged.a | should be b,a
        }
        it 'If passed -Keep, it will Keep the first one' {
            $merged = @{a='b'},[Ordered]@{a='a';b='b';c='c'} | Merge-Splat -Keep
            $merged.keys | should be a,b,c
            $merged.a | should be b
        }
        it 'If passed -Replace, it will Replace collisions with new items' {
            $merged = @{a='b'},[Ordered]@{a='a';b='b';c='c'} | Merge-Splat -Replace
            $merged.keys | should be a,b,c
            $merged.a | should be a
        }
    }

    context 'Find Splat helps you find commands to splat' {
        it 'Will find them within a -Module' {
            @{splat=@{}} | Find-Splat -Module Splatter
        }
        it 'Will find them within a -Module (with a -Command filter)' {
            @{splat=@{}} | Find-Splat -Module Splatter -Command *-Splat
        }
        it 'Will find them commands within the -Local module' {
            @{splat=@{}} | Find-Splat -Local
        }
        it 'Will find them commands within the -Local module (with a -Command filter)' {
            @{splat=@{}} | Find-Splat -Local -Command *-Splat
        }
        <#it 'Will find commands globally (this may take a while)' {
            $foundAnything = @{ThisIsAParameterNameThatShouldNotExist='blah'} | ??@ -Global
            if ($foundAnything -ne $null) { throw "Should not have found a match" }
        }#>
        it 'Will find commands by wildcard' {
            @{id=$pid} | Find-Splat Get-*process*
        }

        it 'Will find splats by specific name' {
            @{id=$pid} | Find-Splat Get-Process
        }

        it 'Will pipe found splats into Use-Splat (use carefully)' {
            @{Id=$pid} | Find-Splat -Global -Command Get*-*Process | Use-Splat
        }
        it 'Will find nothing when passed a module that does not exist' {
            $o=@{Id=$pid} | Find-Splat -Module blalkjdasdlkjdajlks
            if ($o -ne $null) { throw "Somehow it found something" }
        }
        it 'Can find using psBoundParameters' {
            function foo([int]$id) {
                $foundSplat = $PSBoundParameters | Find-Splat -Command get-process
                $foundSplat | Use-Splat
            }

            (foo -id $pid).id|
                should be $pid
        }
    }


    context 'Embedding Splatter is Easy' {
        it 'is as simple as Initialize-Splatter' {
            $embeddedSplatter = Initialize-Splatter
            . ([ScriptBlock]::Create($embeddedSplatter))
            if (${.@} -isnot ([ScriptBlock])) {
                throw 'Splatter failed to embed'
            }
            $splatterModule = Get-Module Splatter
            ${.@} | should not be $splatterModule.ExportedVariables['.@']
            @{id=$pid} | & ${.@} gps
        }

        it 'is pretty small' {
            $embeddedSplatter = Initialize-Splatter
            $embeddedSplatter.Length | should belessthan 30kb
        }

        it 'can be minified and compressed' {
            $embeddedSplatter = Initialize-Splatter -Minify -Compress
            $embeddedSplatter.Length | should belessthan 10kb
        }

        it 'Can be embedded as a functionl' {
            $embeddedSplatter = Initialize-Splatter -Verb Get
            . ([ScriptBlock]::Create($embeddedSplatter))
        }

        it 'can pick out a command or two' {
            $embeddedSplatter = Initialize-Splatter -Verb Get,Use
            ${??@} = $null
            . ([ScriptBlock]::Create($embeddedSplatter))

            if (${??@} -ne $null) {
                throw '${??@} should be undefined'
            }
            $embeddedSplatter.Length | should belessthan 20kb
        }
    }

    context 'Out-Splat' {
        it 'Can write you a splatting script' {
            $splatScript = Out-Splat -CommandName Get-Command -DefaultParameter @{Module='Splatter';CommandType='Alias'}

            $splatScript| should belike '*Get-Command*@*'
        }
        it 'Can write you a splating function' {
            $splatFunction =
                Out-Splat -FunctionName Get-SplatterAlias -CommandName Get-Command -DefaultParameter @{
                    Module='Splatter';CommandType='Alias'
                } -ExcludeParameter * -Synopsis 'Gets Splatter Aliases' -Description 'Gets aliases from the module Splatter'

            $splatFunction | should belike '*function Get-SplatterAlias*{*Get-Command*@*'
        }
    }

    context 'Splatter can be smart about pipelines' {
        it 'Can determine which parameters can pipe' {
            $r =
                @{Foo='Bar';Baz='Bing'} |
                    Get-Splat {
                    param(
                    [Parameter(ValueFromPipelineByPropertyName)]
                    $Foo,

                    $baz
                    )
                }
            $r.PipelineParameter.Keys | should be foo
            $r.NonPipelineParameter.Keys | should be baz
        }

        it 'Can -Stream splats' {
                @{Foo='Bar';Baz='Bing'},
                @{Foo='Foo';Baz='Bing2'} |
                    Use-Splat {
                        param(
                        [Parameter(ValueFromPipelineByPropertyName)]
                        [PSObject]
                        $Foo,

                        $baz
                        )
                        begin { $baz }
                        process { $foo }
                    } -Stream | should be bing,bar,foo
        }
    }

    context 'Splatter tries to be fault-tolerant' {
        it 'Will complain if Use-Splat is not provided with a -Command' {
            $problem = $null
            @{aSplat='IMadeMySelf'} | Use-Splat -ErrorAction SilentlyContinue -ErrorVariable Problem

            if (-not $Problem) { throw "There should hae been a problem" }

        }

        it 'Will output properties containing invalid parameters' {
            $o = @{Date='akllaksjasklj'} | Get-Splat Get-Date -Force
            $o.Invalid.keys | should be Date
        }

        it 'Will mark parameters that could not be turned into a ScriptBlock as invalid' {
            $o = @{Command='{"hi"'} | Get-Splat Invoke-Command -Force
            $o.Invalid.keys | should be Command
        }

    }

}
