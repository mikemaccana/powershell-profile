# Note foreach can be a keyword or an alias to foreach-object
# https://stackoverflow.com/questions/29148462/difference-between-foreach-and-foreach-object-in-powershell

# Set-ExecutionPolicy unrestricted

$profileDir = (get-item $profile).directory.fullname;

# https://technet.microsoft.com/en-us/magazine/hh241048.aspx
$MaximumHistoryCount = 10000

# PS comes preset with 'HKLM' and 'HKCU' drives but is missing HKCR 
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null

# From https://serverfault.com/questions/95431/in-a-powershell-script-how-can-i-check-if-im-running-with-administrator-privil#97599
function Test-Administrator  {  
	$user = [Security.Principal.WindowsIdentity]::GetCurrent();
	(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

function reboot {
	shutdown /r /t 0
}

function edit-powershell-profile {
	edit $profile
}

function update-powershell-profile {
	& $profile
}

# https://blogs.technet.microsoft.com/heyscriptingguy/2012/12/30/powertip-change-the-powershell-console-title
function set-title([string]$newtitle) {
	$host.ui.RawUI.WindowTitle = $newtitle + ' – ' + $host.ui.RawUI.WindowTitle
}

# From http://stackoverflow.com/questions/7330187/how-to-find-the-windows-version-from-the-powershell-command-line
function get-windows-build {
	[Environment]::OSVersion
}

function disable-windows-search {
	Set-Service wsearch -StartupType disabled
	stop-service wsearch
}

# http://mohundro.com/blog/2009/03/31/quickly-extract-files-with-powershell/
# and https://stackoverflow.com/questions/1359793/programmatically-extract-tar-gz-in-a-single-step-on-windows-with-7zip
function expand-archive([string]$file, [string]$outputDir = '') {
	if (-not (Test-Path $file)) {
		$file = Resolve-Path $file
	}

	$baseName = get-childitem $file | select-object -ExpandProperty "BaseName"

	if ($outputDir -eq '') {
		$outputDir = $baseName
	}

	# Check if there's a tar inside
	# We use the .net method as this file (x.tar) doesn't exist!
	$secondExtension = [System.IO.Path]::GetExtension($baseName)
	$secondBaseName = [System.IO.Path]::GetFileNameWithoutExtension($baseName)

	if ( $secondExtension -eq '.tar' ) {
		# This is a tarball
		$outputDir = $secondBaseName
		write-output "Output dir will be $outputDir"		
		7z x $file -so | 7z x -aoa -si -ttar -o"$outputDir"
		return
	} 
	# Just extract the file
	7z x "-o$outputDir" $file	
}

set-alias unzip expand-archive

function get-path {
	($Env:Path).Split(";")
}

# Truncate homedir to ~
function limit-HomeDirectory($Path) {
	$Path.Replace("$home", "~")
}

function Test-FileInSubPath([System.IO.DirectoryInfo]$Child, [System.IO.DirectoryInfo]$Parent) {
	write-host $Child.FullName | select-object '*'
	$Child.FullName.StartsWith($Parent.FullName)
}

Set-Alias trash Remove-ItemSafely

function open($file) {
	invoke-item $file
}

function explorer {
	explorer.exe .
}

function settings {
	start-process ms-setttings:
}

function stree {
	$SourceTreeFolder =  get-childitem ("${env:LOCALAPPDATA}" + "\SourceTree\app*") | Select-Object -first 1
	& $SourceTreeFolder/SourceTree.exe -f .
}

Unblock-File $profileDir\openssl.ps1
. "$profileDir\openssl.ps1"

Unblock-File $profileDir\unix.ps1
. "$profileDir\unix.ps1"

Unblock-File $profileDir\development.ps1
. "$profileDir\development.ps1"

Unblock-File $profileDir\node.ps1
. "$profileDir\node.ps1"

# https://gallery.technet.microsoft.com/scriptcenter/Get-NetworkStatistics-66057d71
#. "$profileDir\Get-NetworkStatistics.ps1"

set-location ~/Documents

write-output 'Mike profile loaded.'
