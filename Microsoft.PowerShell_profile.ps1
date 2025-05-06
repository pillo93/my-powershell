if (-not ( Get-Service -Name "ssh-agent" | Where-Object { $_.Status -eq "Running" }))
{
    Start-Service ssh-agent
}
ssh-add C:\Users\leonardo.pilastri\.ssh\id_rsa

try {
    $null = gh auth status --hostname github.com
    Write-Host "✅ Already authenticated with GitHub CLI."
} catch {
    Write-Host "❌ Not authenticated. Logging in..."
    $GITHUB_TOKEN = Get-Content -Path "${HOME}\git\my-powershell\.ignore\gh_access_token" -Raw
    $GITHUB_TOKEN | gh auth login --with-token
}

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
. "${HOME}\git\my-powershell\sqman\Analyze.ps1"
