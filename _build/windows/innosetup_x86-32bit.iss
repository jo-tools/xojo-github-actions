#define csProductName "Xojo GitHub Actions"
#define csExeName "Xojo GitHub Actions.exe"
#define csAppPublisher "jo-tools.ch"
#define csAppPublisherURL "https://www.jo-tools.ch/"
#define csOutputBaseFilename "Setup_XojoGitHubActions_Windows_x86-32bit"

#define ApplicationVersion	GetFileProductVersion(AddBackslash(SourcePath) + csExeName)

//
// GetStringFileInfo standard names
//
#define COMPANY_NAME       "CompanyName"
#define FILE_DESCRIPTION   "FileDescription"
#define FILE_VERSION       "FileVersion"
#define INTERNAL_NAME      "InternalName"
#define LEGAL_COPYRIGHT    "LegalCopyright"
#define ORIGINAL_FILENAME  "OriginalFilename"
#define PRODUCT_NAME       "ProductName"
#define PRODUCT_VERSION    "ProductVersion"
//
// GetStringFileInfo helpers
//
#define GetFileCompany(str FileName) GetStringFileInfo(FileName, COMPANY_NAME)
#define GetFileCopyright(str FileName) GetStringFileInfo(FileName, LEGAL_COPYRIGHT)
#define GetFileDescription(str FileName) GetStringFileInfo(FileName, FILE_DESCRIPTION)
#define GetFileProductVersion(str FileName) GetStringFileInfo(FileName, PRODUCT_VERSION)
#define GetFileVersionString(str FileName) GetStringFileInfo(FileName, FILE_VERSION)


[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID from the menu.) 
AppId={#csProductName}
AppName={#csProductName}
AppVerName={#csProductName}
AppVersion={#ApplicationVersion}
AppPublisher={#csAppPublisher}
AppPublisherURL={#csAppPublisherURL}

WizardStyle=modern

DefaultDirName={commonpf}\{#csProductName}
;since no icons will be created in "{group}", we don't need the wizard to ask for a group name:
DefaultGroupName=
DisableProgramGroupPage=yes

SourceDir={#sourcepath}
OutputDir=.  
OutputBaseFilename={#csOutputBaseFilename}

Compression=lzma
SolidCompression=yes
ChangesAssociations=yes

; Require Windows 8.1 with Update 1
MinVersion=6.3.9600

Signtool=CodeSignSHA256
SignedUninstaller=yes


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "*"; DestDir: "{app}"; Flags: overwritereadonly recursesubdirs uninsremovereadonly createallsubdirs ignoreversion

[Icons]
Name: "{commondesktop}\{#csProductName}"; Filename: "{app}\{#csExeName}"; Tasks: desktopicon
Name: "{commonprograms}\{#csProductName}"; Filename: "{app}\{#csExeName}"

[Run]
Filename: "{app}\{#csExeName}"; Description: "{cm:LaunchProgram,{#csProductName}}"; Flags: nowait postinstall skipifsilent
