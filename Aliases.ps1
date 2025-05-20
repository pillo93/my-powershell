function g.s
{
    git status @Args
}
function g.aa {
    git add .
}
function g.l
{
    git log $args
}
function g.lg
{
    git log --oneline --graph
}
function g.ck
{
    git checkout @Args
}
function g.ckn
{
    git checkout -B $args[0]
}
function g.pl
{
    git pull
}
function g.ps
{
    git push
}
function g.cmm
{
    git commit -m $args[0]
}
function g.cm
{
    git commit
}
function g.bl
{
    git branch -l
}
function g.br
{
    git branch -r
}
function g.ba
{
    git branch -a
}
function g.fa
{
    git fetch --all
}
function g.rst
{
    git reset --hard HEAD
}
function g.curr
{
    git branch --show-current
}
function g.psn
{
    git push -u origin $( g.curr )
}
function g.psf
{
    git push --force-with-lease
}
function g.d
{
    git diff
}

function cd.sj
{
    Set-Location $HOME/git/sonar-java
}
function cd.ms
{
    Set-Location $HOME/git/sonar-scanner-maven
}
function cd.rspec
{
    Set-Location $HOME/git/rspec
}
function touch
{
    New-Item -Type File -Path $args[0]
}
function grep {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern,

        [Parameter(Position = 1)]
        [string[]]$Path = @("-"),

        [Parameter(ValueFromPipeline = $true)]
        [string]$InputObject,

        [switch]$ic,
        [switch]$n
    )

    begin {
        $slsParams = @{
            Pattern       = $Pattern
            CaseSensitive = -not $ic.IsPresent
            NotMatch      = $n.IsPresent
        }
        $inputBuffer = @()
    }

    process {
        if ($Path -eq "-") {
            if ($InputObject) {
                $inputBuffer += $InputObject
            }
        }
    }

    end {
        if ($Path -eq "-") {
            $inputBuffer | Select-String @slsParams
        } else {
            $slsParams.Path = $Path
            Select-String @slsParams
        }
    }
}
function sha1 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path
    )
    Get-FileHash -Path $Path -Algorithm SHA1 | Select-Object -ExpandProperty Hash
}
Add-Type -AssemblyName "System.IO.Compression.FileSystem"
function jar.classes {
    param([string]$JarPath)

    $jar = [System.IO.Compression.ZipFile]::OpenRead($JarPath)
    $classes = $jar.Entries | Where-Object { $_.FullName -like "*.class" } | ForEach-Object {
        $_.FullName.Replace("/", ".").TrimEnd(".class")
    } | Sort-Object
    $jar.Dispose()
    $classes
}
