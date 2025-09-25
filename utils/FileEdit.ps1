function crlf2lf {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    # Resolve the path to an absolute path for robust checking and operations,
    # though it's often not strictly necessary as PowerShell handles it.
    # This ensures consistency, especially when dealing with PowerShell's location stack.
    $absolutePath = (Get-Item $FilePath).FullName

    if (-not (Test-Path $absolutePath)) {
        Write-Error "File not found: $absolutePath"
        return
    }

    try {
        # Read the content as a single string to ensure correct replacement of CRLF
        $content = [System.IO.File]::ReadAllText($absolutePath)

        # Replace CRLF (`r`n) with LF (`n`)
        $newContent = $content -replace "`r`n", "`n"

        # Write the modified content back to the file
        [System.IO.File]::WriteAllText($absolutePath, $newContent, (New-Object System.Text.UTF8Encoding($false)))

        Write-Host "Converted '$absolutePath' from CRLF to LF successfully."
    } catch {
        Write-Error "An error occurred converting '$absolutePath': $($_.Exception.Message)"
    }
}