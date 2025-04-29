function sq.install {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SQVersion
    )
    $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3" }
    $InstallsFolder = "$HOME\.sqman"
    $numBars = 30

    $candidates = sq.list -Version $SQVersion
    if ($candidates.Count -eq 0) {
        Write-Output "Could not find any matching SQ version"
        return
    }
    if ($candidates.Count -gt 1) {
        Write-Output "Must specify one between:"
        $candidates | ForEach-Object { Write-Output $_ }
        return
    }

    $version = $candidates
    $installPath = Join-Path $InstallsFolder $version
    if (Test-Path $installPath) {
        Write-Output "Sonarqube $version already installed"
        return
    }

    $urlBase = 'https://binaries.sonarsource.com/Distribution/sonarqube/'
    $majorVersion = [int]($version -split '\.')[0]

    if ($majorVersion -lt 4) {
        $zipName = "sonar-$version.zip"
    } else {
        $zipName = "sonarqube-$version.zip"
    }

    $downloadUrl = $urlBase + $zipName
    $filePath = Join-Path $InstallsFolder $zipName

    if (!(Test-Path $InstallsFolder)) {
        New-Item -Path $InstallsFolder -ItemType Directory | Out-Null
    }

    try {
        Write-Output $downloadUrl
        $response = Invoke-WebRequest -Uri $downloadUrl -OutFile $filePath -UseBasicParsing -Headers $headers
    } catch {
        Write-Error "Download error: $($_.Exception.Message)"
        return
    }

    Write-Output "`nFile downloaded and saved to: $filePath"
    Expand-AndRenameZip -ZipPath $filePath -ExtractTo $InstallsFolder -NewName $version
}

function Expand-AndRenameZip {
    param (
        [string]$ZipPath,
        [string]$ExtractTo,
        [string]$NewName
    )

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $ExtractTo)

    $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
    $rootEntry = $zip.Entries | Where-Object { $_.FullName -like "*/*" } | Select-Object -First 1
    $zip.Dispose()

    if (-not $rootEntry) {
        Write-Output "Extraction failed or folder not found."
        return
    }

    $rootFolderName = $rootEntry.FullName.Split('/')[0]
    $oldPath = Join-Path $ExtractTo $rootFolderName
    $newPath = Join-Path $ExtractTo $NewName

    if (Test-Path $oldPath) {
        Rename-Item -Path $oldPath -NewName $NewName
        Write-Output "Extracted folder renamed to: $newPath"
    } else {
        Write-Output "Extraction failed or folder not found."
    }

    Remove-Item -Path $ZipPath
}