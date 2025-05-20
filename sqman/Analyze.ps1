function sq.mvnanalysis {
    param (
        [string]$ProjectKey = "my-project",
        [string]$ProjectName = "My Project",
        [string]$ProjectVersion = "1.0",
        [string]$SonarHostUrl = "http://localhost:9000",
        [string]$SonarToken = $env:SONAR_TOKEN
    )

    if (-not $SonarToken) {
        Write-Output "SonarQube token not provided. Set the SONAR_TOKEN environment variable or pass it explicitly."
        return
    }

    $ssargs = @(
        "-Dsonar.projectKey=$ProjectKey"
        "-Dsonar.projectName=$ProjectName"
        "-Dsonar.projectVersion=$ProjectVersion"
        "-Dsonar.host.url=$SonarHostUrl"
        "-Dsonar.token=$SonarToken"
    )

    mvn sonar:sonar @ssargs
}

function sq.analyze {
    param (
        [string]$ProjectKey = "my-project",
        [string]$ProjectName = "My Project",
        [string]$ProjectVersion = "1.0",
        [string]$SonarHostUrl = "http://localhost:9000",
        [string]$SonarToken = $env:SONAR_TOKEN
    )

    if (-not $SonarToken) {
        Write-Output "SonarQube token not provided. Set the SONAR_TOKEN environment variable or pass it explicitly."
        return
    }

    # Check if sonar-scanner is available
    $scanner = Get-Command "sonar-scanner" -ErrorAction SilentlyContinue
    if (-not $scanner) {
        Write-Output "sonar-scanner is not installed or not in PATH."
        Write-Output "To install sonar-scanner run: sq.install.scannercli"
        return
    }

    $ssargs = @(
        "-Dsonar.projectKey=$ProjectKey"
        "-Dsonar.projectName=$ProjectName"
        "-Dsonar.projectVersion=$ProjectVersion"
        "-Dsonar.sources=."
        "-Dsonar.host.url=$SonarHostUrl"
        "-Dsonar.login=$SonarToken"
    )

    sonar-scanner @ssargs
}

function sq.install.scannercli {
    param (
        [string]$Version = "5.0.1.3006",
        [string]$InstallPath = "$env:ProgramFiles\sonar-scanner"
    )

    $url = "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$Version-windows.zip"
    $zipFile = "$env:TEMP\sonar-scanner.zip"

    if (Test-Path $InstallPath) {
        Write-Host "SonarScanner already installed at $InstallPath"
        return
    }

    Write-Host "Downloading SonarScanner v$Version..."
    Invoke-WebRequest -Uri $url -OutFile $zipFile

    Write-Host "Extracting to $InstallPath..."
    Expand-Archive -Path $zipFile -DestinationPath $InstallPath -Force

    # Adjust path if necessary (due to nested folder)
    $scannerSubDir = Get-ChildItem -Path $InstallPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1
    if ($scannerSubDir -and $scannerSubDir.Name -ne ".") {
        Move-Item "$InstallPath\$($scannerSubDir.Name)\*" $InstallPath -Force
        Remove-Item "$InstallPath\$($scannerSubDir.Name)" -Recurse -Force
    }

    Write-Host "Adding SonarScanner to PATH..."
    $envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if ($envPath -notlike "*$InstallPath\bin*") {
        [System.Environment]::SetEnvironmentVariable(
                "Path",
                "$envPath;$InstallPath\bin",
                [System.EnvironmentVariableTarget]::Machine
        )
        Write-Host "You may need to restart your shell or system for PATH changes to take effect."
    }

    Remove-Item $zipFile -Force
    Write-Host "SonarScanner installed successfully."
}
