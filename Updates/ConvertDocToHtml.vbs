Option Explicit

' Converts all .doc and .docx files in this script's folder to Filtered HTML,
' using Microsoft Word's own "Web Page, Filtered" save format.
'
' Requires Microsoft Word to be installed.
' Output files keep the same base filename with a .html extension.
' Run via the companion "Run Conversion.bat" (uses cscript for console output).

Dim fso, shell, wordApp, scriptFolder, folder, f
Dim regPath, pvNames(2), originalValues(2), i
Dim successCount, failCount

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
scriptFolder = fso.GetParentFolderName(WScript.ScriptFullName)

WScript.Echo "Scanning folder: " & scriptFolder
WScript.Echo ""

Set wordApp = CreateObject("Word.Application")
wordApp.Visible = False
wordApp.DisplayAlerts = 0 ' wdAlertsNone -- auto-dismisses the "this may
                           ' remove Word-specific formatting/tags" warning

' ---- Temporarily disable Protected View ----------------------------------
' Prevents an "Enable Editing" prompt (which nobody could click, since Word
' is invisible) for files that look like they came from the internet, a
' network location, or an email attachment.
regPath = "HKCU\Software\Microsoft\Office\" & wordApp.Version & "\Word\Security\"
pvNames(0) = "DisableInternetFilesInPV"
pvNames(1) = "DisableUnsafeLocationsInPV"
pvNames(2) = "DisableAttachmentsInPV"

For i = 0 To 2
    originalValues(i) = ""
    On Error Resume Next
    originalValues(i) = shell.RegRead(regPath & pvNames(i))
    On Error Goto 0
    shell.RegWrite regPath & pvNames(i), 1, "REG_DWORD"
Next

WScript.Echo "Protected View temporarily disabled for this run."
WScript.Echo ""

successCount = 0
failCount = 0

Set folder = fso.GetFolder(scriptFolder)

Dim ext, baseName, outputPath, doc

For Each f In folder.Files
    ext = LCase(fso.GetExtensionName(f.Name))
    If (ext = "doc" Or ext = "docx") And Left(f.Name, 2) <> "~$" Then

        baseName = fso.GetBaseName(f.Name)
        outputPath = scriptFolder & "\" & baseName & ".html"

        WScript.Echo "Converting: " & f.Name & "  ->  " & baseName & ".html"

        Set doc = Nothing
        On Error Resume Next
        Set doc = wordApp.Documents.Open(f.Path, False, True, False)
        If Err.Number <> 0 Then
            WScript.Echo "  FAILED to open: " & Err.Description
            failCount = failCount + 1
            Err.Clear
            On Error Goto 0
        Else
            On Error Goto 0

            ' Safety net: force out of Protected View if it still triggered.
            If wordApp.ProtectedViewWindows.Count > 0 Then
                Set doc = wordApp.ProtectedViewWindows(wordApp.ProtectedViewWindows.Count).Edit()
            End If

            On Error Resume Next
            doc.SaveAs outputPath, 10 ' wdFormatFilteredHTML
            If Err.Number <> 0 Then
                WScript.Echo "  FAILED to save: " & Err.Description
                failCount = failCount + 1
                Err.Clear
            Else
                successCount = successCount + 1
                WScript.Echo "  OK"
            End If
            On Error Goto 0

            On Error Resume Next
            doc.Close False
            On Error Goto 0
        End If
    End If
Next

' ---- Restore original Protected View settings ----------------------------
For i = 0 To 2
    On Error Resume Next
    If originalValues(i) = "" Then
        shell.RegDelete regPath & pvNames(i)
    Else
        shell.RegWrite regPath & pvNames(i), originalValues(i), "REG_DWORD"
    End If
    On Error Goto 0
Next

wordApp.Quit

WScript.Echo ""
WScript.Echo "Done. " & successCount & " succeeded, " & failCount & " failed."
