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

    $ghrepo = "/repos/adoptium/temurin${javaVersion}-binaries/releases/latest"
    $latest = gh api -H "Accept: application/vnd.github+json" $ghrepo | ConvertFrom-Json
    $javaFullVersion = $latest.tag_name -replace 'jdk-', ''
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
    $jdkFolder = Get-ChildItem -Path $javaInstalls -Directory | Where-Object Name -EQ $latest.tag_name
    if ($jdkFolder)
    {
        # Final name will be for instance: $HOME/java/23
        Rename-Item -Path $jdkFolder.FullName -NewName $javaVersion
    }
    Remove-Item -Path $zipPath
}