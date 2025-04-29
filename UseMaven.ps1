function usemvn {
    param (
        [string]$version
    )

    $basePath = "$HOME\mvn\$version"

    if (Test-Path $basePath) {
        $env:MAVEN_HOME = $basePath
        Update-Path
        Write-Output "PATH updated with $basePath\bin"
    } else {
        Write-Output "Unknown version $version of maven, check if $basePath exists"
        Write-Output "Or install a new mvn with 'getmvn $version'"
    }
}

 usemvn 3.9.9