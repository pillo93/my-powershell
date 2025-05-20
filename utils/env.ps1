function env.checkvar {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Key
    )

    if (-not (Get-ChildItem Env:$Key -ErrorAction SilentlyContinue)) {
        Write-Error "`"$Key`" not found in system environment variables."
        exit 1
    }
}