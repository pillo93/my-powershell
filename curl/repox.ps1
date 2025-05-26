function repox.list(){
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$RepositoryName,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$ArtifactName
    )
    Invoke-WebRequest -Uri "https://repox.jfrog.io/repox/$RepositoryName/org/sonarsource/java/$ArtifactName/maven-metadata.xml" `
    -Headers @{ "Authorization" = "Bearer $($ARTIFACTORY_PASSWORD)" } `
    -OutFile $null # -OutFile $null is equivalent to -o - (output to stdout) in curl for this specific use case, though you might want to redirect to a file if you need to save it.
}