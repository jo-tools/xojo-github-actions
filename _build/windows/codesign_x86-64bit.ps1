# Parameters
$PFX_PASSWORD = $args[0];

# This script requires the following Environment Variables:
# ${env:INNOSETUP_EXE}
# ${env:SIGNTOOL_EXE}
# ${env:CERTIFICATE_PFX}
# ${env:TIMESTAMP_SERVER}
# 
# ${env:FOLDER_BUILDS}
# ${env:FOLDER_BUILDS_WINDOWS_X86_64BIT}
# ${env:BUILD_WINDOWS_APP_FOLDER_NAME}

$FOLDER_CODESIGN = "${env:FOLDER_BUILDS}\${env:FOLDER_BUILDS_WINDOWS_X86_64BIT}\${env:BUILD_WINDOWS_APP_FOLDER_NAME}"

# Perform CodeSign: SHA1 and SHA256
function Do-Codesign([string] $toBeSigned) {
    & "${env:SIGNTOOL_EXE}" sign     /f ${env:CERTIFICATE_PFX} /p "$PFX_PASSWORD" /fd sha1   /t  ${env:TIMESTAMP_SERVER}            /v "$FOLDER_CODESIGN\$toBeSigned"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "CodeSign SHA1 of '$toBeSigned' failed."
        exit 1;
    }
    & "${env:SIGNTOOL_EXE}" sign /as /f ${env:CERTIFICATE_PFX} /p "$PFX_PASSWORD" /fd sha256 /tr ${env:TIMESTAMP_SERVER} /td sha256 /v "$FOLDER_CODESIGN\$toBeSigned"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "CodeSign SHA256 of '$toBeSigned' failed."
        exit 1;
    }
}

# CodeSign: List of Files to be codesigned
Do-Codesign("*.exe")
Do-Codesign("*.dll")
Do-Codesign("${env:BUILD_WINDOWS_APP_FOLDER_NAME} Libs\*.dll")
