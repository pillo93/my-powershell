function repox.list(){
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$RepositoryName,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$ArtifactName
    )
    $url = "https://repox.jfrog.io/repox/${RepositoryName}/org/sonarsource/java/${ArtifactName}/maven-metadata.xml"
    Write-Output $url
    $Response = Invoke-WebRequest -Uri  $url `
    -Headers @{ "Authorization" = "Bearer $($env:ARTIFACTORY_PASSWORD)" } `

    $Response.Content
}