# Install-Module Find-String

# Set-ExecutionPolicy unrestricted

# Install OpenSSH
# Note: do not install chocolatey. Use Install-Package instead.
# Get-PackageProvider
# Get-PackageSource -Provider chocolatey
# Install-Package -Name openssh
Add-PathVariable "${env:ProgramFiles}\OpenSSH"
Add-PathVariable "${env:ProgramFiles}\rethinkdb"
Add-PathVariable "${env:ProgramFiles}\7-Zip"
Add-PathVariable "${env:ProgramFiles}\wtrace"
Add-PathVariable "C:\OpenSSL-Win32\bin"
Add-PathVariable "${env:ProgramFiles}\nodejs"
# Add-PathVariable "${env:UserProfile}\AppData\Local\Atlassian\SourceTree\git_local\bin"


#
#
# $env:NODE_PATH = "C:\Users\mike\AppData\Roaming\npm"

# For 'Remove-ItemSafely' - ie, trashing files from the command line
# Install-Module -Name Recycle
Set-Alias trash Remove-ItemSafely

function edit-powershell-profile {
	subl $profile
}

# For working less (except in ISE)
# Install-Package Pscx

# For history with up/down arrows
# Install-Package PSReadLine
Import-Module PSReadLine

# https://gallery.technet.microsoft.com/WHOIS-PowerShell-Function-ed69fde6
Unblock-File $home\scripts\whois.ps1
. $home\scripts\whois.ps1

# https://technet.microsoft.com/en-us/magazine/hh241048.aspx
$MaximumHistoryCount = 10000



# Tab completion for git
# Install-Module posh-git
# Load posh-git example profile
# . 'C:\Users\mike\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

# https://gallery.technet.microsoft.com/scriptcenter/Get-NetworkStatistics-66057d71
. 'C:\Users\mike\powershell\Get-NetworkStatistics.ps1'

function uptime {
	Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';
	EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

function edit-powershell-profile {
	subl $profile
}

function reload-powershell-profile {
	& $profile
}

# https://blogs.technet.microsoft.com/heyscriptingguy/2012/12/30/powertip-change-the-powershell-console-title
function change-title([string]$newtitle) {
	$host.ui.RawUI.WindowTitle = $newtitle + ' – ' + $host.ui.RawUI.WindowTitle
}

# From http://stackoverflow.com/questions/7330187/how-to-find-the-windows-version-from-the-powershell-command-line
function get-windows-build {
	[Environment]::OSVersion
}

# http://mohundro.com/blog/2009/03/31/quickly-extract-files-with-powershell/
function unarchive([string]$file, [string]$outputDir = '') {
	if (-not (Test-Path $file)) {
		$file = Resolve-Path $file
	}

	if ($outputDir -eq '') {
		$outputDir = [System.IO.Path]::GetFileNameWithoutExtension($file)
	}

	7z e "-o$outputDir" $file
}

#######################################################
# Prompt Tools
#######################################################

# https://github.com/gummesson/kapow/blob/master/themes/bashlet.ps1
function prompt {
	$realLASTEXITCODE = $LASTEXITCODE
	Write-Host $(Truncate-HomeDirectory("$pwd")) -ForegroundColor Yellow -NoNewline
	Write-Host " $" -NoNewline
	$global:LASTEXITCODE = $realLASTEXITCODE
	Return " "
}

function Truncate-HomeDirectory($Path) {
	$Path.Replace("$home", "~")
}

function Test-FileInSubPath([System.IO.DirectoryInfo]$Child, [System.IO.DirectoryInfo]$Parent) {
	write-host $Child.FullName | select '*'
	$Child.FullName.StartsWith($Parent.FullName)
}

# Produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues["Out-File:Encoding"]="utf8"

#######################################################
# Dev Tools
#######################################################
function subl {
	& "$env:ProgramFiles\Sublime Text 3\subl.exe" @args
}

function explorer {
	explorer.exe .
}

function gg {
	& git grep -n -i @args
}

function stree {
	$SourceTreeCommand = (Get-ItemProperty HKCU:\Software\Classes\sourcetree\shell\open\command).'(default)'.split()[0].replace('"','')
	& $SourceTreeCommand -f .
}

function open($file) {
	ii $file
}

# http://stackoverflow.com/questions/39148304/fuser-equivalent-in-powershell/39148540#39148540
function fuser($relativeFile){
	$file = Resolve-Path $relativeFile
	echo "Looking for processes using $file"
	foreach ( $Process in (Get-Process)) {
		foreach ( $Module in $Process.Modules) {
			if ( $Module.FileName -like "$file*" ) {
				$Process | select id, path
			}
		}
	}
}

#######################################################
# Useful shell aliases
#######################################################

function findfile($name) {
	ls -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach {
		$place_path = $_.directory
		echo "${place_path}\${_}"
	}
}

function get-path {
	($Env:Path).Split(";")
}

function git-show-ignored {
	git ls-files . --ignored --exclude-standard --others
}

function git-show-untracked {
	git ls-files . --exclude-standard --others
}

#######################################################
# Unixlike commands
#######################################################

function df {
	get-volume
}

function cut($delimiter, $fieldNumber) {
	$input | ForEach-Object { $_.split($delimiter)[$fieldNumber] }
}

function sed($file, $find, $replace){
	(Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function sed-recursive($filePattern, $find, $replace) {
	$files = ls . "$filePattern" -rec -Exclude
	foreach ($file in $files) {
		(Get-Content $file.PSPath) |
		Foreach-Object { $_ -replace "$find", "$replace" } |
		Set-Content $file.PSPath
	}
}

function grep($regex, $dir) {
	if ( $dir ) {
		ls $dir | select-string $regex
		return
	}
	$input | select-string $regex
}

function grepv($regex) {
	$input | ? { !$_.Contains($regex) }
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

# Should really be name=value like Unix version of export but not a big deal
function export($name, $value) {
	set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
	ps $name -ErrorAction SilentlyContinue | kill
}

function pgrep($name) {
	ps $name
}

function touch($file) {
	"" | Out-File $file -Encoding ASCII
}

# From https://stackoverflow.com/questions/894430/creating-hard-and-soft-links-using-powershell
function make-link ($target, $link) {
	New-Item -Path $link -ItemType SymbolicLink -Value $target
}

# From https://github.com/keithbloom/powe	rshell-profile/blob/master/Microsoft.PowerShell_profile.ps1
function sudo {
	$file, [string]$arguments = $args;
	$psi = new-object System.Diagnostics.ProcessStartInfo $file;
	$psi.Arguments = $arguments;
	$psi.Verb = "runas";
	$psi.WorkingDirectory = get-location;
	[System.Diagnostics.Process]::Start($psi) >> $null
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

function unzip ($file) {
	$dirname = (Get-Item $file).Basename
	echo("Extracting", $file, "to", $dirname)
	New-Item -Force -ItemType directory -Path $dirname
	expand-archive $file -OutputPath $dirname -ShowProgress
}

# From https://certsimple.com/blog/openssl-shortcuts
function openssl-view-certificate ($file) {
	echo "openssl x509 -text -noout -in $file"
	openssl x509 -text -noout -in $file
}

function openssl-view-csr ($file) {
	echo "openssl req -text -noout -verify -in $file"
	openssl req -text -noout -verify -in $file
}

function openssl-view-rsa-key ($file) {
	echo openssl rsa -check -in $file
	openssl rsa -check -in $file
}

function openssl-view-rsa-key ($file) {
	echo "openssl rsa -check -in $file"
	openssl rsa -check -in $file
}

function openssl-view-ecc-key ($file) {
	echo "openssl ec -check -in $file"
	openssl ec -check -in $file
}



function openssl-view-pkcs12 ($file) {
	echo "openssl pkcs12 -info -in $file"
	openssl pkcs12 -info -in $file
}

# Connecting to a server (Ctrl C exits)
function openssl-client ($server) {
	echo "openssl s_client -status -connect $server:443"
	openssl s_client -status -connect $server:443
}

# Convert PEM private key, PEM certificate and PEM CA certificate (used by nginx, Apache, and other openssl apps)
# to a PKCS12 file (typically for use with Windows or Tomcat)
function openssl-convert-pem-to-p12 ($key, $cert, $cacert, $output) {
	echo "openssl pkcs12 -export -inkey $key -in $cert -certfile $cacert -out $output"
	openssl pkcs12 -export -inkey $key -in $cert -certfile $cacert -out $output
}

# Convert a PKCS12 file to PEM
function openssl-convert-p12-to-pem ($p12file, $pem) {
	echo "openssl pkcs12 -nodes -in $p12file -out $pemfile"
	openssl pkcs12 -nodes -in $p12file -out $pemfile
}

# Convert a crt to a pem file
function openssl-crt-to-pem($crtfile) {
	echo "openssl x509 -in $crtfile -out $basename.pem -outform PEM"
	openssl x509 -in $crtfile -out $basename.pem -outform PEM
}

# Check the modulus of an RSA certificate (to see if it matches a key)
function openssl-check-rsa-certificate-modulus {
	echo "openssl x509 -noout -modulus -in "${1}" | shasum -a 256"
	openssl x509 -noout -modulus -in "${1}" | shasum -a 256
}

# Check the modulus of an ECDSA certificate (to see if it matches a key)
function openssl-check-ecdsa-certificate-modulus {
	echo "openssl x509 -noout -modulus -in "${1}" | shasum -a 256"
	openssl x509 -noout -pubkey -in "${1}" | shasum -a 256
}

# Check the modulus of an RSA key (to see if it matches a certificate)
function openssl-check-rsa-key-modulus {
	echo "openssl rsa -noout -modulus -in "${1}" | shasum -a 256"
	openssl rsa -noout -modulus -in "${1}" | shasum -a 256
}

# Check the modulus of an ECDSA key (to see if it matches a certificate)
function openssl-check-rsa-key-modulus {
	echo "openssl pkey -pubout -in "${1}" | shasum -a 256"
	openssl pkey -pubout -in "${1}" | shasum -a 256
}

# Check the modulus of a certificate request
function openssl-check-key-modulus {
	echo openssl req -noout -modulus -in "${1}" | shasum -a 256
	openssl req -noout -modulus -in "${1}" | shasum -a 256
}

# Encrypt a file (because zip crypto isn't secure)
function openssl-encrypt () {
	echo openssl aes-256-cbc -in "${1}" -out "${2}"
	openssl aes-256-cbc -in "${1}" -out "${2}"
}

# Decrypt a file
function openssl-decrypt () {
	echo aes-256-cbc -d -in "${1}" -out "${2}"
	openssl aes-256-cbc -d -in "${1}" -out "${2}"
}

# For setting up public key pinning
function openssl-key-to-hpkp-pin() {
	echo openssl rsa -in "${1}" -outform der -pubout | openssl dgst -sha256 -binary | openssl enc -base64
	openssl rsa -in "${1}" -outform der -pubout | openssl dgst -sha256 -binary | openssl enc -base64
}

# For setting up public key pinning (directly from the site)
function openssl-website-to-hpkp-pin() {
	echo openssl s_client -connect "${1}":443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
	openssl s_client -connect "${1}":443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
}

# Combines the key and the intermediate in a unified PEM file
# (eg, for nginx)
function openssl-key-and-intermediate-to-unified-pem() {
	echo echo -e "$(cat "${1}")\n$(cat "${2}")" > "${1:0:-4}"_unified.pem
	echo -e "$(cat "${1}")\n$(cat "${2}")" > "${1:0:-4}"_unified.pem
}

# http://stackoverflow.com/questions/39221953/can-i-make-powershell-tab-complete-show-me-all-options-rather-than-picking-a-sp
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

echo 'Mike profile loaded.'
