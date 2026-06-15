on run
	set launcher to my launcherPath()
	do shell script quoted form of launcher
end run

on open fileList
	set launcher to my launcherPath()
	set commandText to quoted form of launcher
	repeat with fileRef in fileList
		set commandText to commandText & " " & quoted form of POSIX path of fileRef
	end repeat
	do shell script commandText
end open

on launcherPath()
	return (POSIX path of (path to home folder)) & "dotfiles/bin/open-in-neovim-wezterm"
end launcherPath
