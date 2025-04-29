function usejava {
    param (
        [string]$version
    )

    $basePath = "$HOME\java\$version"

    if (Test-Path $basePath) {
        $env:JAVA_HOME = $basePath
        Write-Output "JAVA_HOME set to: $basePath"
        Update-Path
    } else {
        Write-Output "Unknown version $version of java, check if $basePath exists"
        Write-Output "Or install a new jdk with 'getjava $version'"
    }
}

 usejava 23