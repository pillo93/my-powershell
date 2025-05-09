function sq.list
{
    param (
        [string]$Version
    )

    try
    {
        $response = gh api "repos/SonarSource/sonarqube/tags?per_page=100" | ConvertFrom-Json
    }
    catch
    {
        Write-Error "Failed to fetch data from GitHub: $_"
        return
    }

    $versions = @()

    foreach ($tag in $response)
    {
        $name = $tag.name
        if ($null -eq $Version -or $name -like "$Version*")
        {
            if ($name -match '^\d+\.\d+\.\d+\.?\d*$')
            {
                $versions += $name
            }
        }
    }

    return $versions
}

function sq.plugins
{
    param (
        [Parameter(Mandatory = $true)]
        [string]$SQVersion
    )

    $majorVersion = [int]$SQVersion.Split('.')[0]
    $headers = @{ "User-Agent" = "PowerShell" }
    $candidates = sq.list -Version $SQVersion
    if ($candidates.Count -eq 0)
    {
        Write-Output "Could not find any matching SQ version"
        return
    }
    if ($candidates.Count -gt 1)
    {
        Write-Output "Must specify one between:"
        $candidates | ForEach-Object { Write-Output $_ }
        return
    }

    $SQVersion = $candidates

    if ($majorVersion -ge 8)
    {
        $url = "http://raw.githubusercontent.com/SonarSource/sonarqube/$SQVersion/build.gradle"
        $pattern = "dependency\s+'([^']+-plugin[^']*)'"
    }
    elseif ($majorVersion -ge 7)
    {
        $url = "http://raw.githubusercontent.com/SonarSource/sonarqube/$SQVersion/sonar-application/build.gradle"
        $pattern = "bundledPlugin\s+'([^']+-plugin[^']*)'"
    }
    else
    {
        Write-Output "Version not supported"
        return
    }

    try
    {
        $response = Invoke-WebRequest -Uri $url -Headers $headers
    }
    catch
    {
        Write-Error ("ERROR fetching $url :" + $_.Exception.Message)
    }

    $output = ""

    foreach ($line in $response.Content -split "`n")
    {
        $match = [regex]::Match($line, $pattern)
        if ($match.Success)
        {
            $plugin = $match.Groups[1].Value -split ':' | Select-Object -Skip 1
            $output += ($plugin -join ' ') + "`n"
        }
    }

    Write-Output $output

}