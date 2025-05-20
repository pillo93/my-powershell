$env:ARTIFACTORY_API_KEY = Get-Content "${HOME}\tokens\mend_script_repox_token"
$env:MEND_USER_KEY = Get-Content "${HOME}\tokens\mend_user_token"
$products = @{
    'sonar-xml' = 'b09cb9337d19490b918b6312578874f04975ca9431eb42b1a127ddc372c5e924'
    'sonar-scanner-maven'= 'd3c00c6b702441c484c10d8253fda402d13a2f56d9214c4f9f942998e7418322'
    'sonar-scanner-gradle'= '9a2b5c9635514cc0beb8e27fe4213a6b13e25b17c79e4fbd99706f0da0484808'
    'sonar-java'= '0702ab75a4b1426ca010b96d4c743712d45c43d283a443e78387f959b9dc08f1'
    'sonar-scala'= '25ba3ceda28f44148f0bffa26c276242381a97b4ccd242c6a57e8b98e990e74c'
    'sonar-ruby'= '6632dfc43c9c4051a884b5620481f064dd30fca4e5104a9a9aa761af059239ff'
}
$MendBaseUrl = 'https://api-saas-eu.whitesourcesoftware.com'
$UserEmail = 'leonardo.pilastri@sonarsource.com'
$UserKey = $env:MEND_TOKEN
$OrgToken = 'b868c5617282407f9bb67bfcfec3b2eb9db13ab5b4204b2d85789ebf79e48612'
$headers = @{
    "Content-Type" = "application/json"
}


function mend.scan
{
    usejava 24
    cd "${HOME}\git\languages-experimental-tooling\squad\javakotlin\mend-shipped-depencencies"
    mvn package exec:java

}

function mend.ignored {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Product, # The specific product token you want to query
        [Parameter(Mandatory=$false)]
        [string]$Version,    # For local filtering after retrieval
        [Parameter(Mandatory=$false)]
        [string]$Artifact    # For local filtering after retrieval
    )
    $ProductToken =  $products[$Product]
    # 1. Login to get JWT
    $loginUrl = "$MendBaseUrl/api/v2.0/login"
    $loginBody = @{
        email = $UserEmail
        userKey = $UserKey
        orgToken = $OrgToken
    } | ConvertTo-Json
    try {
        $loginResponse = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $loginBody -ContentType "application/json"
        $jwtToken = $loginResponse.retVal.jwtToken
    } catch {
        Write-Error "Failed to login to Mend API: $($_.Exception.Message)"
        return $null
    }

    $alertsUrl = "$MendBaseUrl/api/v2.0/products/$ProductToken/alerts/security"
    $alertsHeaders = @{
        "Authorization" = "Bearer $jwtToken"
        "Content-Type" = "application/json"
    }

    $queryParams = @{
        "status" = "IGNORED"
        "page"   = 0 
        "size"   = 50 
    }
    if($Version) {
        $queryParams["search"] = "projectName:like:$Version"
    }

    $allIgnoredAlerts = @()
    $fullAlertsUrl = $alertsUrl + "?" + ($queryParams.Keys | ForEach-Object { "$_=$($queryParams.$_)" }) -join '&'

    try {
        $alertsResponse = Invoke-RestMethod -Uri $fullAlertsUrl -Method Get -Headers $alertsHeaders
        $allIgnoredAlerts += $alertsResponse.retVal 
    } catch {
        Write-Error "Error fetching ignored alerts: $($_.Exception.Message)"
        Write-Error "Full error: $($_.Exception | Format-List -Force)"
        break # Exit loop on error
    }
    
    $allIgnoredAlerts | Convert-Mend-Alert-Data
}

function Convert-Mend-Alert-Data(){
    param(
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        [object]$alerts
    )
    $res = @()
    foreach ($alert in $alerts) {
        $res += @{
            "id" = $alert.uuid
            "CVE" = $alert.name
            "artifact" = $alert.component.groupId + ":" + $alert.component.artifactId + ":" + $alert.component.version
            "vulnerability" = $alert.vulnerability.description
            "project" = $alert.project.name
            "status" = $alert.alertInfo.status
            "comment" = $alert.alertInfo.comment
            "topFix" = $alert.topFix.fixResolution
        }
    }
    $res | ConvertTo-Json | Format-Table -AutoSize
}