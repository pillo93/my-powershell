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

. "C:\Users\leonardo.pilastri\Documents\WindowsPowerShell\Aliases.ps1"
. "C:\Users\leonardo.pilastri\Documents\WindowsPowerShell\UseJava.ps1"
. "C:\Users\leonardo.pilastri\Documents\WindowsPowerShell\GetJava.ps1"
. "C:\Users\leonardo.pilastri\Documents\WindowsPowerShell\UseMaven.ps1"
. "C:\Users\leonardo.pilastri\Documents\WindowsPowerShell\GetMaven.ps1"
. "C:\Users\leonardo.pilastri\Documents\WindowsPowerShell\InstallFortClientCert.ps1"
. "C:\Users\leonardo.pilastri\Documents\WindowsPowerShell\sqman\Discover.ps1"
. "C:\Users\leonardo.pilastri\Documents\WindowsPowerShell\sqman\Install.ps1"
