function install_forticlient_cert_java()
{

    $java_install_folder = "$HOME/java"

    Get-ChildItem -Path $java_install_folder -Directory | ForEach-Object {
        $version = $_.Name

        # This sets JAVA_HOME to the one we want to install the cert on
        usejava $version
        keytool -import -trustcacerts `
        -keystore "$env:JAVA_HOME/lib/security/cacerts" `
        -storepass changeit -noprompt -alias fortinet `
        -file "$HOME/Sonar.cer"

        keytool -import -trustcacerts `
        -keystore cacerts `
        -storepass changeit -noprompt -alias fortinet `
        -file "$HOME/Sonar.cer"
    }

}