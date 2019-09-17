
# Just a couple of things (sed, to interpret sed scripts) from http://unxutils.sourceforge.net/
Add-PathVariable "${env:ProgramFiles}\UnxUtils"

# Note PSReadLine uses vi keybindings by default. If you want emacs enable:
# Set-PSReadlineOption -EditMode Emacs
# I like vi keybindings, so I just add my favourite one from emacs
# See https://github.com/lzybkr/PSReadLine#usage
Set-PSReadlineKeyHandler -Key 'Escape,_' -Function YankLastArg

# Change how powershell does tab completion
# http://stackoverflow.com/questions/39221953/can-i-make-powershell-tab-complete-show-me-all-options-rather-than-picking-a-sp
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

# For dig, host, etc.
Add-PathVariable "${env:ProgramFiles}\ISC BIND 9\bin"

# Should really be name=value like Unix version of export but not a big deal
function export($name, $value) {
	set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
	get-process $name -ErrorAction SilentlyContinue | stop-process
}

function pgrep($name) {
	get-process $name
}

# Like Unix touch, creates new files and updates time on old ones
# PSCX has a touch, but it doesn't make empty files
Remove-Alias touch
function touch($file) {
	if ( Test-Path $file ) {
		Set-FileTime $file
	} else {
		New-Item $file -type file
	}
}

# From https://stackoverflow.com/questions/894430/creating-hard-and-soft-links-using-powershell
function ln($target, $link) {
	New-Item -ItemType SymbolicLink -Path $link -Value $target
}

set-alias new-link ln

# http://stackoverflow.com/questions/39148304/fuser-equivalent-in-powershell/39148540#39148540
function fuser($relativeFile){
	$file = Resolve-Path $relativeFile
	write-output "Looking for processes using $file"
	foreach ( $Process in (Get-Process)) {
		foreach ( $Module in $Process.Modules) {
			if ( $Module.FileName -like "$file*" ) {
				$Process | select-object id, path
			}
		}
	}
}

# https://gallery.technet.microsoft.com/WHOIS-PowerShell-Function-ed69fde6
Unblock-File $PSScriptRoot\whois.ps1
. $PSScriptRoot\whois.ps1

function uptime {
	Get-CimInstance Win32_OperatingSystem | select-object csname, @{LABEL='LastBootUpTime';
	EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

function df {
	get-volume
}

# Todo: look at 'edit-file' from PSCX
# Repalced with real 'sed' to interpret sed scripts
# function sed($file, $find, $replace){
# 	(Get-Content $file).replace("$find", $replace) | Set-Content $file
# }

# Like a recursive sed
function edit-recursive($filePattern, $find, $replace) {
	$files = get-childitem . "$filePattern" -rec # -Exclude
	write-output $files
	foreach ($file in $files) {
		(Get-Content $file.PSPath) |
		Foreach-Object { $_ -replace "$find", "$replace" } |
		Set-Content $file.PSPath
	}
}
function grep($regex, $dir) {
	if ( $dir ) {
		get-childitem $dir | select-string $regex
		return
	}
	$input | select-string $regex
}

function grepv($regex) {
	$input | where-object { !$_.Contains($regex) }
}

function show-links($dir){
	get-childitem $dir | where-object {$_.LinkType} | select-object FullName,LinkType,Target
}

function which($name) {
	Get-Command $name | Select-Object -ExpandProperty Definition
}

function cut(){
	foreach ($part in $input) {
		$line = $part.ToString();
		$MaxLength = [System.Math]::Min(200, $line.Length)
		$line.subString(0, $MaxLength)
	}
}

function Private:file($file) {
	$extension = (Get-Item $file).Extension
	$fileType = (get-itemproperty "Registry::HKEY_Classes_root\$extension")."(default)"
	$description =  (get-itemproperty "Registry::HKEY_Classes_root\$fileType")."(default)"
	write-output $description
}

# From https://github.com/Pscx/Pscx
function sudo(){
	Invoke-Elevated @args
}

# https://gist.github.com/aroben/5542538
function pstree {
	$ProcessesById = @{}
	foreach ($Process in (Get-WMIObject -Class Win32_Process)) {
		$ProcessesById[$Process.ProcessId] = $Process
	}

	$ProcessesWithoutParents = @()
	$ProcessesByParent = @{}
	foreach ($Pair in $ProcessesById.GetEnumerator()) {
		$Process = $Pair.Value

		if (($Process.ParentProcessId -eq 0) -or !$ProcessesById.ContainsKey($Process.ParentProcessId)) {
			$ProcessesWithoutParents += $Process
			continue
		}

		if (!$ProcessesByParent.ContainsKey($Process.ParentProcessId)) {
			$ProcessesByParent[$Process.ParentProcessId] = @()
		}
		$Siblings = $ProcessesByParent[$Process.ParentProcessId]
		$Siblings += $Process
		$ProcessesByParent[$Process.ParentProcessId] = $Siblings
	}

	function Show-ProcessTree([UInt32]$ProcessId, $IndentLevel) {
		$Process = $ProcessesById[$ProcessId]
		$Indent = " " * $IndentLevel
		if ($Process.CommandLine) {
			$Description = $Process.CommandLine
		} else {
			$Description = $Process.Caption
		}

		Write-Output ("{0,6}{1} {2}" -f $Process.ProcessId, $Indent, $Description)
		foreach ($Child in ($ProcessesByParent[$ProcessId] | Sort-Object CreationDate)) {
			Show-ProcessTree $Child.ProcessId ($IndentLevel + 4)
		}
	}

	Write-Output ("{0,6} {1}" -f "PID", "Command Line")
	Write-Output ("{0,6} {1}" -f "---", "------------")

	foreach ($Process in ($ProcessesWithoutParents | Sort-Object CreationDate)) {
		Show-ProcessTree $Process.ProcessId 0
	}
}

function find-file($name) {
	get-childitem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach-object {
		write-output($PSItem.FullName)
	}
}

set-alias find find-file
set-alias find-name find-file

function reboot {
	shutdown /r /t 0
}


