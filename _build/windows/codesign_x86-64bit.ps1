# Parameters
$PFX_PASSWORD = $args[0];

# This script requires the following Environment Variables:
# Signtool
# ${env:SIGNTOOL_EXE}
# ${env:TIMESTAMP_SERVER}
# 
# Azure Trusted Signing
# ${env:AZURE_TENANT_ID}
# ${env:AZURE_CLIENT_ID}
# ${env:AZURE_CLIENT_SECRET}
# ${env:ACS_DLIB}
# ${env:ACS_JSON}
#
# Build Location
# ${env:FOLDER_BUILDS}
# ${env:FOLDER_BUILDS_WINDOWS_X86_64BIT}
# ${env:BUILD_WINDOWS_APP_FOLDER_NAME}

$FOLDER_CODESIGN = "${env:FOLDER_BUILDS}\${env:FOLDER_BUILDS_WINDOWS_X86_64BIT}\${env:BUILD_WINDOWS_APP_FOLDER_NAME}"

# Perform CodeSign: SHA256
function Do-Codesign([string] $toBeSigned) {
    & "${env:SIGNTOOL_EXE}" sign /fd sha256 /tr ${env:TIMESTAMP_SERVER} /td sha256 /v /dlib "${env:ACS_DLIB}" /dmdf "${env:ACS_JSON}" "$FOLDER_CODESIGN\$toBeSigned"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Azure Trusted Signing: CodeSign SHA256 of '$toBeSigned' failed."
        exit 1;
    }
}

# CodeSign: List of Files to be codesigned
Do-Codesign("*.exe")
Do-Codesign("*.dll")
Do-Codesign("${env:BUILD_WINDOWS_APP_FOLDER_NAME} Libs\*.dll")
