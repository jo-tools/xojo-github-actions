#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  If (args.LastIndex < 1) Then
		    PrintUsage
		    Return 0
		  End If
		  
		  Dim arg As String
		  
		  For i As Integer = 1 To args.LastIndex
		    arg = args(i).Trim
		    If arg = "-?" Or arg = "-h" Then
		      PrintUsage
		      Return 0
		    ElseIf arg = "-v" Then
		      PrintVersionInfo
		      Return 0
		    ElseIf arg = "-x" Then
		      IDEComm = New IDECommunicatorv2(args(i+1).Trim)
		      Exit 'Loop
		    End If
		  Next
		  
		  If (IDEComm = Nil) Then IDEComm = New IDECommunicatorv2
		  
		  For i As Integer = 1 To args.LastIndex
		    arg = args(i).Trim
		    If arg = "-x" Then
		      args.RemoveAt(i+1)
		    ElseIf arg = "-i" Then
		      IDEComm.SendScript(String.FromArray(Slice(args, i + 1)))
		      WaitForSocketToFinish
		      Return 0
		    ElseIf arg = "-c" Then
		      PrintPath
		      Return 0
		    ElseIf arg = "-s" Then
		      SendStdin
		      Return 0
		    ElseIf arg <> "" And arg.Left(1) <> "-" Then
		      SendFile(arg)
		      Return 0
		    ElseIf arg <> "" Then
		      stderr.WriteLine(kAppName + ": illegal option -- " + arg)
		      PrintUsage
		      Return 1
		    End If
		  Next
		  
		  // No arguments
		  PrintUsage
		  Return 0
		  
		End Function
	#tag EndEvent

	#tag Event
		Function UnhandledException(error As RuntimeException) As Boolean
		  stderr.WriteLine(kAppName + ": Unhandled exception.")
		  stderr.Write(String.FromArray(error.Stack, EndOfLine)) + EndOfLine
		  Quit(1)
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub PrintPath()
		  stdout.WriteLine(kAppName + ":IDE Communication Path: " + IDEComm.FindIPCPath)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PrintUsage()
		  stdout.WriteLine(kAppName + " version " + Me.Version)
		  stdout.WriteLine(" ")
		  stdout.WriteLine("usage: IDECommunicator [-x IPCPath] [-i command] [-v] [-c] [-s] [-?] [-h] [file]")
		  stdout.WriteLine(" ")
		  stdout.WriteLine(kAppName + " sends script commands to the Xojo IDE.")
		  stdout.WriteLine("Options:")
		  stdout.WriteLine("   -x IPCPath: use this IPCPath. Needs to be the first argument")
		  stdout.WriteLine("   -i command: send the given one-line command")
		  stdout.WriteLine("   -v: print version information and exit")
		  stdout.WriteLine("   -c: report the communications path and exit")
		  stdout.WriteLine("   -s: read input from stdin, send and exit")
		  stdout.WriteLine("   -? or -h: print this help screen and exit")
		  stdout.WriteLine("   file: send the contents of the given file and exit")
		  stdout.WriteLine(" ")
		  stdout.WriteLine("If neither file nor -i is given, then script input is read from stdin")
		  stdout.WriteLine("until end-of-input (Ctrl+D).")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PrintVersionInfo()
		  stdout.WriteLine(kAppName + " version " + me.Version)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ResolvePath(path As String) As FolderItem
		  // GetFolderItem doesn't resolve relative paths when using
		  // PathTypeShell.  So check for that, and hack around it.
		  Var IsAbsolutePath As Boolean
		  
		  #if TargetWindows Then
		    isAbsolutePath = path.Left(1) >= "A" And Path.Left(1) <= "Z" And Path.Middle(1, 2) = ":\"
		  #Else
		    isAbsolutePath = path.Left(1) = "/"
		  #EndIf
		  
		  If isAbsolutePath Then
		    // Absolute path; should work fine
		    Return New FolderItem(path, FolderItem.PathModes.Shell)
		  End If
		  
		  #If TargetWindows Then
		    // Relative paths are not supports on windows
		    Dim err As New InvalidArgumentException("Relative paths are not supported; use an absolute path")
		    Raise err
		  #EndIf
		  
		  // Relative path; jam it onto the current working directory.
		  // ToDo: find a way to accomplish this on Windows, or get
		  // this feature added.
		  Const kPathSep As String = "/"
		  Dim prefix As String
		  prefix = System.EnvironmentVariable("PWD")
		  If prefix.Right(1) <> kPathSep Then 
		    prefix = prefix + kPathSep
		  End If
		  
		  Return new FolderItem(prefix + path, FolderItem.PathModes.Shell)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SendFile(path As String)
		  // Send a file at the given path to the IDE.
		  // But watch out for a first line that starts with "#!"; this is 
		  // a shell script interpreter, and not part of the script itself.
		  
		  Dim f As FolderItem
		  f = ResolvePath(path)
		  If f = Nil Or Not f.Exists Then
		    stderr.Write(kAppName + ": unable to locate file: ")
		    If f <> Nil Then stderr.WriteLine(f.NativePath) Else stderr.WriteLine(path)
		    Quit(1)
		    Return
		  End If
		  
		  Dim fileContent As String
		  Try
		    Dim firstLine As String
		    Dim inp As TextInputStream = TextInputStream.Open(f)
		    
		    firstLine = inp.ReadLine + EndOfLine
		    If firstLine.Left(2) = "#!" Then firstLine = ""
		    
		    fileContent = firstLine + inp.ReadAll
		    inp.Close
		  Catch err As RuntimeException
		    stderr.WriteLine(kAppName + ": unable to read file: " + path)
		    Quit(1)
		    Return
		  End Try
		  
		  IDEComm.SendScript(fileContent)
		  WaitForSocketToFinish
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SendStdin()
		  // Read from stdin until end-of-input, and send
		  // that data to the IDE.
		  
		  Dim buffer As String
		  While Not stdin.EOF
		    buffer = buffer + stdin.ReadLine + EndOfLine
		  Wend
		  
		  IDEComm.SendScript(buffer)
		  
		  WaitForSocketToFinish
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Slice(strArray() As String, fromPos As Integer=0, toPos As Integer = -1) As String()
		  // Return a subset of the given array.
		  
		  Dim ub As Integer = strArray.LastIndex
		  
		  Dim startIdx As Integer = fromPos
		  If startIdx < 0 Then startIdx = ub + 1 + startIdx
		  
		  Dim endIdx As Integer = toPos
		  If endIdx < 0 Then endIdx = ub + 1 + endIdx
		  
		  Dim out() As String
		  If endIdx >= startIdx Then
		    Redim out(endIdx - startIdx)
		    For i As Integer = startIdx To endIdx
		      out(i - startIdx) = strArray(i)
		    Next
		  End If
		  
		  Return out
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WaitForSocketToFinish()
		  While Not IDEComm.Finished
		    App.DoEvents(500)
		  Wend
		End Sub
	#tag EndMethod


	#tag Note, Name = Mods
		
		Parameter: -x
		-> set IPCPath (select XojoVersion)
		
		IPCSocket.Error
		-> Quit(ErrorCode)
		-> QuitIDE - no error
		
		
	#tag EndNote

	#tag Note, Name = Terminal
		Launch Xojo
		***********
		env XOJO_IPCPATH=Xojo2022r2 /Applications/Xojo/Xojo\ 2022\ Release\ 2/Xojo\ 2022r2.app/Contents/MacOS/Xojo &
		
		Send Script
		***********
		./IDECommunicator -x Xojo2022r1 ./testscript.xojo_script
		
		Quit Xojo
		*********
		osascript -e 'quit app "Xojo 2022r"'
	#tag EndNote


	#tag Property, Flags = &h21
		Private IDEComm As IDECommunicatorv2
	#tag EndProperty


	#tag Constant, Name = kAppName, Type = String, Dynamic = False, Default = \"XojoIDECommunicator", Scope = Protected
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
