function mend.scan
{
    $env:ARTIFACTORY_API_KEY = Get-Content "${HOME}\tokens\mend_script_repox_token"
    $env:MEND_USER_KEY = Get-Content "${HOME}\tokens\mend_user_token"
    usejava 24
    cd "${HOME}\git\languages-experimental-tooling\squad\javakotlin\mend-shipped-depencencies"
    mvn package exec:java

}
