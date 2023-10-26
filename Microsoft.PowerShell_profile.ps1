### PowerShell template profile 
### Version 1.3 - Bert Nieuwenampsen <bert@trebnie.nl>
###
# ------------------------------ Variable ------------------------------
# path to you favorite editing tool
$editor="c:\program files\notepad++\notepad++.exe"

# Find out if the current user identity is elevated (has admin rights)
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# ------------------------------ Functions ------------------------------
function custom-functions(){
	$tab = [char]9
	write-host "The custom functions are defined in: " -foregroundcolor white
	write-host $profile -foregroundcolor green
	write-host ""
	write-host "Custom profile functions:" -foregroundcolor white
	write-host "* System" -foregroundcolor yellow
	write-host "df $tab$tab" -nonewline 
	write-host ": get disk volumes" -foregroundcolor green
	write-host "get-pubip $tab" -nonewline 
	write-host ": get public ip" -foregroundcolor green
	write-host "pgrep $tab$tab" -nonewline 
	write-host ": find a process" -foregroundcolor green
	write-host "pkill $tab$tab" -nonewline 
	write-host ": kill a process" -foregroundcolor green
	
	write-host "* Files and Directories" -foregroundcolor yellow
	write-host "dirs $tab$tab" -nonewline 
	write-host ": show all directories and subdirectories (recursive)" -foregroundcolor green
	write-host "edit $tab$tab" -nonewline 
	write-host ": start the preferred editor" -foregroundcolor green
	write-host "find-file (ff)$tab" -nonewline 
	write-host ": find file in current directory and subdirectories (recursive)" -foregroundcolor green	
	write-host "gotodir (gd) $tab" -nonewline 
	write-host ": go to a directory even if the path has a file name" -foregroundcolor green
	write-host "grep $tab$tab" -nonewline 
	write-host ": find files by filename and content in current directory and subdirectories (recursive)" -foregroundcolor green	
	write-host "ll $tab$tab" -nonewline 
	write-host ": show all files in current directory" -foregroundcolor green
	write-host "touch $tab$tab" -nonewline 
	write-host ": create empty file" -foregroundcolor green
	write-host "unzip $tab$tab" -nonewline 
	write-host ": compress file or dir in current directory" -foregroundcolor green
	write-host "unzip $tab$tab" -nonewline 
	write-host ": extract zip in current directory" -foregroundcolor green

	write-host "* General" -foregroundcolor yellow
	write-host "admin (sudo,su)$tab$tab" -nonewline 
	write-host ": start powershell in admin mode" -foregroundcolor green
	write-host "test-commandexists $tab" -nonewline 
	write-host ": test if a command exists" -foregroundcolor green
	write-host "sync $tab$tab$tab" -nonewline 
	write-host ": sync this profile ps1 based on modification date to other versions" -foregroundcolor green
}

# If so and the current host is a command line, then change to red color 
# as warning to user that they are operating in an elevated context
# Useful shortcuts for traversing directories
function cd...  { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }

# Compute file hashes - useful for checking successful downloads 
function md5    { Get-FileHash -Algorithm MD5 $args }
function sha1   { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

# Drive shortcuts
function HKLM:  { Set-Location HKLM: }
function HKCU:  { Set-Location HKCU: }
function Env:   { Set-Location Env: }

# shows a different prompt when admin and when not
function prompt { 
    if ($isAdmin) {
        "[" + (Get-Location) + "] # " 
    } else {
        "[" + (Get-Location) + "] $ "
    }
}

# Does the the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
function dirs{
    if ($args.Count -gt 0) {
        Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
    } else {
        Get-ChildItem -Recurse | Foreach-Object FullName
    }
}

# list all files in current directory
function ll { get-childitem -path $pwd -file }

# find files by filename
function find-file($name) {
        Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
                $place_path = $_.directory
                Write-Output "${place_path}\${_}"
        }
}
# find files by filename and content
function grep($regex, $dir) {
        if ($dir) {
			get-childitem $dir | select-string $regex
			return
        } else {
			get-childitem $pwd | select-string $regex
			return
		}
}

# unzip in current dir
function unzip ($file) {
	write-output("extracting", $file, "to", $pwd)
	$fullfile = get-childitem -path $pwd -filter .\cove.zip | foreach-object{$_.fullname}
	expand-archive -path $fullfile -destinationpath $pwd
}


# compressing (zip)
function zip ($source) {
	write-host ""
	write-host "------ Compressing (zip) ------"
	# filename determination
	$items = get-item $source
	if ($items.count -gt 1) {
		# multiple files, first file givens the name
		write-host "Total items: $($items.count)"
		$filename = $($items[0].fullname)
	} else {
		write-host "Total items: 1"
		$filename = $($items.fullname)
	}
	# write-host "Source: $filename"
	
	# $target = ((get-item -path $filename).fullname).trimend('\')
	$target = ($filename).trimend('\')
	$zipdir = split-path -parent "$target.zip"
	$zipfile = ("$target").replace("$zipdir\","")
		
	write-host "Target directory: $zipdir"
	write-host "Filename: $zipfile.zip"
	
	$output = "$zipdir\$zipfile.zip"
	if (test-path $output) {
		write-host "File allready exist: $zipfile" -foregroundcolor yellow
		write-host "Options: (r)ename, (o)verwrite, (t)imestamp"
		$answer = read-host "Other options will stop this action"
		if (($answer -ne "r") -and ($answer -ne "o") -and ($answer -ne "t")) {
			write-host "No choice made, nothing done"
			write-host "-------------------------------"
			break
		}
	}

	if ($answer -eq "r") {
		$tmp = read-host "Filename (excl zip)"
		write-host "Option: rename"
		$zipfile = "$tmp.zip"
	}
	if ($answer -eq "t") {
		write-host "Option: add timestamp"
		[string]$tmp = get-date -format "yyyymmdd-hhmm"
		$zipfile = "$zipfile-$tmp.zip"
	}

	$output = "$zipdir\$zipfile.zip"
	try {
		if ($answer -eq "o") {
			write-host "Overwrite existing file: $source -> $output.zip"
			$tmp = compress-archive -path $source -destinationpath $output -force -erroraction stop
		} else {
			write-host "Compressing: $source -> $output.zip"
			$tmp = compress-archive -path $source -destinationpath $output -erroraction stop
		}
	}
	catch {
		$tmp = $error[0].exception.message
		write-host "Zip file not created" -foregroundcolor yellow
		write-host $tmp -foregroundcolor white
	}
	write-host "-------------------------------"
}

# starts current powershell version as admin
function admin {
	# get current process and start this as admin.
	$pwshell = [system.diagnostics.process]::getcurrentprocess().processname
    if ($args.Count -gt 0) {   
       $argList = "& '" + $args + "'"
       Start-Process $pwshell -Verb runAs -ArgumentList $argList
    } else {
       Start-Process $pwshell -Verb runAs
    }
}

# test if a command exists
function Test-CommandExists {
	Param ($command)
	$oldPreference = $ErrorActionPreference
	$ErrorActionPreference = 'SilentlyContinue'
	try {if(Get-Command $command){RETURN $true}}
	Catch {Write-Host "$command does not exist"; RETURN $false}
	Finally {$ErrorActionPreference=$oldPreference}
}

# go to a directory even in path is a file.
function gotodir($dir) {
	if ((get-item $dir -erroraction silentlycontinue ) -is [system.io.directoryinfo]) {
		cd $dir
	} else {
		cd (split-path -path $dir)
	}
}

# kill a process
function pkill($name) {
        Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}
# find a process
function pgrep($name) {
	if ($name) {
		Get-Process $name | sort name
	} else {
		Get-Process | sort name
	}
}

# get public ip
function get-pubip {
	(invoke-webrequest http://ifconfig.me/ip ).content
}

# create empty file
function touch($file) {
        "" | out-file $file -encoding ascii
}

# get disk volumes
function df {
        get-volume
}

# search and replace in a file
function sed($file, $find, $replace){
        (Get-Content $file).replace("$find", $replace) | Set-Content $file
}

# find out which command you can use
function which($name) {
        Get-Command $name | Select-Object -ExpandProperty Definition
}

# ------------------------------ Aliasses ------------------------------
set-alias -name vim -value $editor
set-alias -name edit -value $editor

set-alias -name gd -value gotodir
set-alias -name ff -value find-file

# set unix-like aliases for the admin command, so sudo <command> will run the command a admin
set-alias -name su -value admin
set-alias -name sudo -value admin

# ------------------------------ Commands ------------------------------

$Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
if ($isAdmin) {
    $Host.UI.RawUI.WindowTitle += " [ADMIN]"
}

write-host "start '"  -nonewline -foregroundcolor white
write-host "custom-functions" -nonewline -foregroundcolor green
write-host "' to get a list of the custom options." -foregroundcolor white


# ------------------------------ CleanUp ------------------------------
# We don't need these any more; they were just temporary variables to get to $isAdmin. 
# Delete them to prevent cluttering up the user profile. 
Remove-Variable identity
Remove-Variable principal
