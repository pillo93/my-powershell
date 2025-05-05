if (-not ( Get-Service -Name "ssh-agent" | Where-Object { $_.Status -eq "Running" }))
{
    Start-Service ssh-agent
}
ssh-add C:\Users\leonardo.pilastri\.ssh\id_rsa

Import-Module posh-git
Add-PoshGitToProfile -AllHosts

$initialPath = $env:PATH
$env:MAVEN_HOME = ""

function Update-Path()
{
    $env:PATH = "$env:JAVA_HOME\bin;" + "$env:MAVEN_HOME\bin;" + $initialPath
}

. "${HOME}\git\my-powershell\Aliases.ps1"
. "${HOME}\git\my-powershell\UseJava.ps1"
. "${HOME}\git\my-powershell\GetJava.ps1"
. "${HOME}\git\my-powershell\UseMaven.ps1"
. "${HOME}\git\my-powershell\GetMaven.ps1"
. "${HOME}\git\my-powershell\InstallFortClientCert.ps1"
. "${HOME}\git\my-powershell\sqman\Discover.ps1"
. "${HOME}\git\my-powershell\sqman\Install.ps1"
. "${HOME}\git\my-powershell\sqman\Run.ps1"
