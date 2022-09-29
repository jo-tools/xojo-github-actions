#tag Class
Protected Class IDECommunicatorv2
Inherits IPCSocket
	#tag Event
		Sub DataAvailable()
		  Dim jsonData As String = Self.ReadAll
		  Dim jsonText As String
		  Dim errorCode As Integer
		  
		  #Pragma BreakOnExceptions False
		  Try
		    Dim js As New JSONItem(jsonData)
		    js.Compact = False
		    jsonText = js.ToString
		    
		    If js.HasKey("scriptError") Then errorCode = 2
		    If js.HasKey("projectError") Then errorCode = 3
		    If js.HasKey("openErrors") Then errorCode = 4
		    If js.HasKey("buildError") Then errorCode = 5
		    
		  Catch ex As JSONException
		    jsonText = jsonData
		  End Try
		  
		  Print jsonText
		  
		  If (errorCode > 0) Then
		    Quit(errorCode)
		  End If
		  
		  Finished = True
		End Sub
	#tag EndEvent

	#tag Event
		Sub Error(err As RuntimeException)
		  If ebScriptIsQuittingIDE And Self.LastErrorCode = 102 Then
		    'Quit IDE - lost connection -> OK
		    Print "Script requested to quit the Xojo IDE. Lost connection to the IDE, so this is expected."
		    Quit(0)
		    Return
		  End If
		  
		  stderr.WriteLine("IPC Socket Error: " + Str(Self.LastErrorCode))
		  stderr.WriteLine(err.Message + " (" + Str(err.ErrorNumber) + ")")
		  
		  If ebIsConnecting Then
		    Print "Connecting to the Xojo IDE via IPC Path '" + Self.Path + "' failed. Maybe Xojo is not running?"
		  End If
		  
		  
		  Quit(Self.LastErrorCode)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor()
		  Self.Path = FindIPCPath
		  
		  ebIsConnecting = True
		  Self.Connect
		  ebIsConnecting = False
		    
		  // Send initial JSON to tell Xojo to use IDE Communicator v2 protocol
		  Dim js As New JSONItem
		  js.Value("protocol") = 2
		  Self.Write(js.ToString + Chr(0))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(useIPCPath As String)
		  self.IPCPath = useIPCPath
		  self.Constructor()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindIPCPath() As String
		  // Find a path for our temp file.
		  Dim parent As FolderItem
		  
		  Try
		    parent = folderitem.DriveAt(0).Child("tmp")
		  Catch err As NilObjectException
		    parent = Nil
		  End Try
		  
		  If parent Is Nil Or Not parent.exists Or Not parent.IsWriteable Then
		    // Handle WUBI installed Ubuntu (is really odd and Volume(0) fails)
		    Try
		      parent = folderitem.DriveAt(0).Child("var").Child("tmp")
		    Catch err As NilObjectException
		      parent = Nil
		    End Try
		  End If
		  
		  If parent Is Nil Or Not parent.exists Or Not parent.IsWriteable Then
		    // Handle WUBI installed Ubuntu (is really odd and Volume(0) fails)
		    Try
		      parent = SpecialFolder.Temporary
		    Catch err As NilObjectException
		      parent = Nil
		    End Try
		  End If
		  
		  If parent Is Nil Or Not parent.exists Or Not parent.IsWriteable Then
		    // Handle WUBI installed Ubuntu (is really odd and Volume(0) fails)
		    Try
		      parent = SpecialFolder.Home
		    Catch err As NilObjectException
		      parent = Nil
		    End Try
		  End If
		  
		  Try
		    Return parent.Child(ipcpath).ShellPath
		  Catch err As NilObjectException
		    Return ""
		  End Try
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendScript(source As String)
		  // Create JSON for script
		  Dim js As New JSONItem
		  js.Value("tag") = "build"
		  js.Value("script") = source
		  
		  ebScriptIsQuittingIDE = (source.IndexOf("QuitIDE") >= 0)
		  
		  Self.Write(js.ToString + Chr(0))
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private ebIsConnecting As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ebScriptIsQuittingIDE As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Finished As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private IPCPath As String = "XojoIDE"
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Path"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Finished"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
