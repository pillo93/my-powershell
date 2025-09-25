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
    $GITHUB_TOKEN = Get-Content -Path "${HOME}\tokens\gh_access_token" -Raw
    $GITHUB_TOKEN | gh auth login --with-token
}

$initialPath = $env:PATH
$env:MAVEN_HOME = ""

function Update-Path()
{
    $env:PATH = "$env:JAVA_HOME\bin;" + "$env:MAVEN_HOME\bin;" + $initialPath
}

function prompt {
    $path = (Get-Location).Path
    $parts = $path -split '\\'
    $short = ($parts[0..($parts.Length - 2)] | ForEach-Object { $_[0] }) -join '\'
    $short += "\" + $parts[-1]
    # Get Git status (if any)
    $git = Write-VcsStatus
    # Return the full prompt string
    "$short $git> "
}

. "${HOME}\git\my-powershell\utils\env.ps1"
. "${HOME}\git\my-powershell\utils\FileComparing.ps1"
. "${HOME}\git\my-powershell\utils\FileEdit.ps1"
. "${HOME}\git\my-powershell\Aliases.ps1"
. "${HOME}\git\my-powershell\UseJava.ps1"
. "${HOME}\git\my-powershell\GetJava.ps1"
. "${HOME}\git\my-powershell\UseMaven.ps1"
. "${HOME}\git\my-powershell\GetMaven.ps1"
. "${HOME}\git\my-powershell\InstallFortClientCert.ps1"
. "${HOME}\git\my-powershell\sqman\Discover.ps1"
. "${HOME}\git\my-powershell\sqman\Install.ps1"
. "${HOME}\git\my-powershell\sqman\Run.ps1"
. "${HOME}\git\my-powershell\mendy\Mend.ps1"
. "${HOME}\git\my-powershell\sqman\Analyze.ps1"
. "${HOME}\git\my-powershell\curl\repox.ps1"
