function crlf2lf {
    param (
    # Single mandatory parameter for the file or directory path
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path
    )

    # --- Internal Conversion Logic (Same as before) ---
    function Convert-File {
        param([string]$Path)

        $absolutePath = (Get-Item $Path).FullName

        try {
            # Use [System.IO.File]::ReadAllText for reading
            # Note: Default ReadAllText uses UTF-8 encoding unless a BOM is detected.
            $content = [System.IO.File]::ReadAllText($absolutePath)

            # Replace CRLF (`r`n) with LF (`n`)
            $newContent = $content -replace "`r`n", "`n"

            # Check if content changed before writing back
            if ($content -ne $newContent) {
                # Use [System.IO.File]::WriteAllText for writing (UTF8 without BOM for Unix compatibility)
                # The $false in the UTF8Encoding constructor prevents the BOM.
                [System.IO.File]::WriteAllText($absolutePath, $newContent, (New-Object System.Text.UTF8Encoding($false)))
                Write-Host "Converted '$absolutePath' from CRLF to LF successfully." -ForegroundColor Green
            } else {
                Write-Host "Skipped '$absolutePath'. Already using LF or no changes needed." -ForegroundColor Yellow
            }
        } catch {
            Write-Error "An error occurred converting '$absolutePath': $($_.Exception.Message)"
        }
    }
    # ---------------------------------

    # --- Main Execution Logic ---

    # 1. Check if the path exists
    if (-not (Test-Path $Path)) {
        Write-Error "Path not found: $Path"
        return
    }

    # 2. Determine if it's a file or directory
    if (Test-Path $Path -PathType Leaf) {
        # It's a file, convert it directly
        Write-Host "Processing single file: $Path"
        Convert-File -Path $Path

    } elseif (Test-Path $Path -PathType Container) {
        # It's a directory, recursively find and convert all files
        Write-Host "Processing directory recursively: $Path"

        # Get all files recursively (-File ensures only files are returned, -Recurse goes into subdirectories)
        $files = Get-ChildItem -Path $Path -File -Recurse -ErrorAction Stop

        if ($files.Count -eq 0) {
            Write-Host "No files found recursively in '$Path'." -ForegroundColor Yellow
            return
        }

        foreach ($file in $files) {
            Convert-File -Path $file.FullName
        }

    } else {
        # Handle other types of paths (e.g., symlinks, drives without leaf/container type)
        Write-Error "The specified path '$Path' is neither a file nor a directory."
    }
}