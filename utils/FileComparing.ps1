function files.comparedir(){
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path1,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Path2,
        [Parameter(Mandatory=$false, Position=2)]
        [string]$Matching = "*"
    )
    # compare the sha1 hashes of all files in two directories and finds which are the same
    $files1 = Get-ChildItem -Path $Path1 -Recurse -Include $Matching | Where-Object { -not $_.PSIsContainer }
    $files2 = Get-ChildItem -Path $Path2 -Recurse -Include $Matching | Where-Object { -not $_.PSIsContainer }

    $hashes1 = @{}
    foreach ($file in $files1) {
        $hash = Get-FileHash -Path $file.FullName -Algorithm SHA1
        $hashes1[$hash.Hash] = $file.FullName
    }
    $hashes2 = @{}
    foreach ($file in $files2) {
        $hash = Get-FileHash -Path $file.FullName -Algorithm SHA1
        $hashes2[$hash.Hash] = $file.FullName
    }
    $commonHashes = $hashes1.Keys | Where-Object { $hashes2.ContainsKey($_) }
    $result = @()
    foreach ($hash in $commonHashes) {
        $result += $hashes1[$hash]
    }
    if ($result.Count -eq 0) {
        Write-Output "No matching files found."
    } else {
        Write-Output "Matching files found:"
        $result | Sort-Object | Format-Table -AutoSize
    }

}