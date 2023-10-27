# Powershell Profile
Pretty PowerShell that looks good and functions almost as good as Linux terminal 

## Favo editor
set path to your favorite editor<br>
$editor="c:\program files\notepad++\notepad++.exe"

## One Line Install (Elevated PowerShell Recommended)

```
irm "https://github.com/bertman80/powershell-profile/raw/main/setup.ps1" | iex
```

## Fix the Missing Font
Extract the downloaded `cove.zip` that is in the folder you ran the script from and install the nerd fonts. 

# Sync-profile:
You can use sync-profile.ps1 to sync the microsoft.powershell_profile.ps1 between version 5 and version 7.<br>
This script will copy the file with the latest writetime to the other profile.


# Last updates:
01-nov-2022: added gotodir function <br>
03-nov-2022: improve admin function <br>

# Custom profile functions:
* System
```
df              : get disk volumes
get-pubip       : get public ip
pgrep           : find a process
pkill           : kill a process
```
* Files and Directories
```
dirs            : show all directories and subdirectories (recursive)
edit            : start the preferred editor
find-file       : find file in current directory and subdirectories (recursive)
gotodir (gd)    : go to a directory even if the path has a file name
grep            : find files by filename and content in current directory and subdirectories (recursive)
ll              : show all files in current directory
touch           : create empty file
unzip           : extract zip in current directory
zip             : compress files and folders
```
* General
```
admin (sudo,su)         : start powershell in admin mode
test-commandexists      : test if a command exists
```
