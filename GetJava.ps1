function getjava
{
    param ([string] $javaVersion)
    $javaInstalls = "$HOME\java"
    $destinationPath = "$javaInstalls\$javaVersion"
    if (Test-Path -Path  $destinationPath)
    {
        Write-Output $destinationPath" already exists"
        return
    }

    $ghrepo = "/repos/adoptium/temurin${javaVersion}-binaries/releases"
    $releases = gh api -H "Accept: application/vnd.github+json" $ghrepo | ConvertFrom-Json
    $tags = $releases | Select-Object -ExpandProperty tag_name

    # Display numbered list
    for ($i = 0; $i -lt $tags.Count; $i++) {
        Write-Host "$($i + 1): $($tags[$i])"
    }
    $selection = Read-Host "Enter the number of the release you want to select"
    if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $tags.Count) {
        $chosenTag = $tags[$selection - 1]
        Write-Host "You selected: $chosenTag"
    } else {
        Write-Host "Invalid selection. Please run the script again and choose a valid number."
    }

    $javaFullVersion = $chosenTag -replace 'jdk-', ''
    Write-Output "Installing Java ${javaFullVersion}"

    $javaUriVersion = $javaFullVersion -replace '\+', '%2B'
    $javaFileVersion = $javaFullVersion -replace '\+', '_'

    $arch = "x64"
    $repo = "https://github.com/adoptium/temurin${javaVersion}-binaries"
    $binaryUrl = "${repo}/releases/download/jdk-${javaUriVersion}/OpenJDK${javaVersion}U-jdk_${arch}_windows_hotspot_${javaFileVersion}.zip"

    # Download the file
    $zipPath = "$env:TEMP\openjdk_${javaFileVersion}.zip"
    Write-Output "Download from '$binaryUrl' into '$zipPath'"
    Invoke-WebRequest -Uri $binaryUrl -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $javaInstalls
    $jdkFolder = Get-ChildItem -Path $javaInstalls -Directory | Where-Object Name -EQ $chosenTag
    if ($jdkFolder)
    {
        # Final name will be for instance: $HOME/java/23
        $major = $chosenTag -replace '^jdk-(\d+)\+.*$', '$1'
        Rename-Item -Path $jdkFolder.FullName -NewName $major
    }
    Remove-Item -Path $zipPath
}
