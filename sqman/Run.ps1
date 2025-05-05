function Get-SonarqubePID {
    $processes = Get-Process java -ErrorAction SilentlyContinue
    foreach ($p in $processes) {
        try {
            $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($p.Id)").CommandLine
            if ($cmdLine -and $cmdLine.ToLower().Contains(".sqman")) {
                return $p.Id
            }
        } catch {
            continue
        }
    }
    return $null
}

function sq.start {
    param (
        [string]$SQVersion = ""
    )
    $SQVersion = "$SQVersion"  # force string in case it's miscast
    $choices = sq.installed $SQVersion
    if ($choices.Count -eq 0) {
        Write-Host "Sonarqube $SQVersion is not installed!"
        Write-Host "Run `"sqman install $SQVersion`" to install it"
        return
    }
    elseif ($choices.Count -gt 1) {
        Write-Host "Must specify one between:"
        $choices | ForEach-Object { Write-Host $_ }
        return
    }

    $torun = $choices
    $installsFolder = "$env:USERPROFILE\.sqman"
    $installPath = Join-Path $installsFolder $torun

    if (-not (Test-Path $installPath)) {
        Write-Host "Sonarqube $torun is not installed!!"
        Write-Host "Run `"sqman install $torun`" to install it"
        return
    }

    Write-Host "Starting Sonarqube $torun ..."
    $shell = $null
    $os = $env:OS

    $binPath = Join-Path $installPath "bin\windows-x86-64\StartSonar.bat"

    if (-not (Test-Path $binPath)) {
        Write-Host "Start script not found at $binPath"
        return
    }

    Write-Host "Running command: $binPath"
    try {
        if ($shell) {
            Start-Process -FilePath $shell -ArgumentList "$binPath start" -NoNewWindow
        } else {
            Start-Process -FilePath $binPath -NoNewWindow
        }

        Start-Sleep -Seconds 3

        $realPid = Get-SonarqubePID
        if ($realPid) {
            Write-Host "SonarQube started with PID: $realPid"
            $pidFile = "$env:USERPROFILE\.sqman\current.pid"
            Set-Content -Path $pidFile -Value $realPid
        } else {
            Write-Host "Failed to detect SonarQube PID. It may not have started correctly."
        }
    } catch {
        Write-Host "An error occurred: $_"
    }
}
