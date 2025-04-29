function getmvn
{
    param ([string] $mvnVersion)
    $mvnInstalls = "$HOME\mvn"
    $destinationPath = "$mvnInstalls\$mvnVersion"
    if (Test-Path -Path  $destinationPath)
    {
        Write-Output $destinationPath" already exists"
        return
    }

    $major = $mvnVersion.Split('.')[0]
    Write-Output "Installing Maven ${mvnVersion}"
    $zipFile = "apache-maven-${mvnVersion}-bin.zip"

    $binaryUrl = "https://downloads.apache.org/maven/maven-${major}/${mvnVersion}/binaries/${zipFile}"

    # Download the file
    $zipPath = "$env:TEMP\${zipFile}"
    Write-Output "Download from '$binaryUrl' into '$zipPath'"
    Invoke-WebRequest -Uri $binaryUrl -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $mvnInstalls
    $mvnInstall = Get-ChildItem -Path $mvnInstalls -Directory | Where-Object Name -EQ "apache-maven-${mvnVersion}"
    if ($mvnInstall)
    {
        Rename-Item -Path $mvnInstall.FullName -NewName $mvnVersion
    }
    Remove-Item -Path $zipPath
}