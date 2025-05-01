function g.s
{
    git status @Args
}
function g.l
{
    git log
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
function g.rst()
{
    git reset --hard HEAD
}
function g.curr()
{
    git branch --show-current
}
function g.psn()
{
    git push -u origin $( g.curr )
}
function g.psf()
{
    git push --force-with-lease
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
Set-Alias g.d "git diff"
Set-Alias grep "Select-String"

