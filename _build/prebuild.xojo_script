// Open Xojo Project
OpenFile(EnvironmentVariable("GITHUB_WORKSPACE") + "/" + EnvironmentVariable("XOJO_PROJECT_FILE"))

// Build Settings
Dim sVersion As String = PropertyValue("App.MajorVersion") + "." + PropertyValue("App.MinorVersion") + "." + PropertyValue("App.BugVersion")

If (PropertyValue("App.NonReleaseVersion") <> "0") Then PropertyValue("App.NonReleaseVersion") = "0"
If (PropertyValue("App.ShortVersion") <> sVersion) Then PropertyValue("App.ShortVersion") = sVersion
If (PropertyValue("App.LongVersion") <> "jo-tools.ch") Then PropertyValue("App.LongVersion") = "jo-tools.ch"


Dim sStageCode As String = "0" 'Development
Select Case EnvironmentVariable("BUILD_STAGE_CODE")
Case "final"
sStageCode = "3"
Case "beta"
sStageCode = "2"
Case "alpha"
sStageCode = "1"
End Select
If (PropertyValue("App.StageCode") <> sStageCode) Then PropertyValue("App.StageCode") = sStageCode

Print "Xojo Pre Build Script finished."
