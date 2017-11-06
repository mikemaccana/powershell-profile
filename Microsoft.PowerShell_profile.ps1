# Install-Module Find-String

# Set-ExecutionPolicy unrestricted

# For OpenSSH
# Note: do not install chocolatey. Use Install-Package instead.
# Get-PackageProvider
# Get-PackageSource -Provider chocolatey
# Install-Package -Name openssh

# For working less (except in ISE)
# Install-Package Pscx

# For history with up/down arrows, other useful vi/emacs keybindings
# Install-Package PSReadLine

# For 'Remove-ItemSafely' - ie, trashing files from the command line
# Install-Module -Name Recycle

Add-PathVariable "${env:ProgramFiles}\OpenSSH"
Add-PathVariable "${env:ProgramFiles}\rethinkdb"
Add-PathVariable "${env:ProgramFiles}\7-Zip"
Add-PathVariable "${env:ProgramFiles}\wtrace"
Add-PathVariable "C:\OpenSSL-Win32\bin"
Add-PathVariable "${env:ProgramFiles}\nodejs"
Add-PathVariable "${env:ProgramFiles(x86)}\Yarn\bin"

# Add relative node_modules\.bin to PATH - this keeps updating as we `cd`
Add-PathVariable '.\node_modules\.bin'

# To use git supplied by SourceTree instead of the 'git for Windows' version
# Add-PathVariable "${env:UserProfile}\AppData\Local\Atlassian\SourceTree\git_local\bin"

# $env:NODE_PATH = "C:\Users\mike\AppData\Roaming\npm"



Import-Module PSReadLine
# Note PSReadLine uses vi keybindings by default. If you want emacs (default on Linux)
# Set-PSReadlineOption -EditMode Emacs
# I like vi keybindings, so I just add my favourite one from emacs
# See https://github.com/lzybkr/PSReadLine#usage
Set-PSReadlineKeyHandler -Key 'Escape,_' -Function YankLastArg

# https://technet.microsoft.com/en-us/magazine/hh241048.aspx
$MaximumHistoryCount = 10000

# PS comes preset with 'HKLM' and 'HKCU' drives but is missing HKCR
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

# Produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues["Out-File:Encoding"]="utf8"

# http://stackoverflow.com/questions/39221953/can-i-make-powershell-tab-complete-show-me-all-options-rather-than-picking-a-sp
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

# Tab completion for git
# Install-Module posh-git
# Load posh-git example profile
# . 'C:\Users\mike\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

#######################################################
# General useful Windows-specific commands
#######################################################

# https://gallery.technet.microsoft.com/scriptcenter/Get-NetworkStatistics-66057d71
. 'C:\Users\mike\powershell\Get-NetworkStatistics.ps1'

# Kinda like $EDITOR in nix
# You may prefer eg 'subl' or whatever else
function edit {
	& "code-insiders" -g @args
}

function subl {
	echo "Type 'edit' instead"
}

function edit-powershell-profile {
	edit $profile
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

function gg {
	# Replace file:linenumber:content with file:linenumber:content
	# so you can just click the file:linenumber and go straight there.
	& git grep -n -i @args | % { $_ -replace '(\d+):','$1 ' }  
}

Set-Alias trash Remove-ItemSafely
function open($file) {
	ii $file
}


#######################################################
# Dev Tools
#######################################################
function subl {
	& "$env:ProgramFiles\Sublime Text 3\subl.exe" @args
}

function explorer {
	explorer.exe .
}
function stree {
	$SourceTreeFolder =  ls ("${env:LOCALAPPDATA}" + "\SourceTree\app*") | Select-Object -first 1
	& $SourceTreeFolder/SourceTree.exe -f .
}




#######################################################
# Unixlike commands
#######################################################

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

# https://gallery.technet.microsoft.com/WHOIS-PowerShell-Function-ed69fde6
Unblock-File $home\scripts\whois.ps1
. $home\scripts\whois.ps1


function uptime {
	Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';
	EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

function df {
	get-volume
}

function sed($file, $find, $replace){
	(Get-Content $file).replace("$find", $replace) | Set-Content $file
}
function sed-recursive($filePattern, $find, $replace) {
	$files = ls . "$filePattern" -rec # -Exclude
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
function ln($target, $link) {
	New-Item -ItemType SymbolicLink -Path $link -Value $target
}

function make-link {
	ln
}

function file($file) {
	$extension = (Get-Item $file).Extension
	$fileType = (gp "Registry::HKEY_Classes_root\$extension")."(default)"
	$description =  (gp "Registry::HKEY_Classes_root\$fileType")."(default)"
	echo $description
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

# Check the public point value of an ECDSA certificate (to see if it matches a key)
# See https://security.stackexchange.com/questions/73127/how-can-you-check-if-a-private-key-and-certificate-match-in-openssl-with-ecdsa
function openssl-check-ecdsa-certificate-ppv-and-curve {
	echo "openssl x509 -in "${1}" -pubkey | shasum -a 256"
	openssl x509 -noout -pubkey -in "${1}" | shasum -a 256
}

# Check the modulus of an RSA key (to see if it matches a certificate)
function openssl-check-rsa-key-modulus {
	echo "openssl rsa -noout -modulus -in "${1}" | shasum -a 256"
	openssl rsa -noout -modulus -in "${1}" | shasum -a 256
}

# Check the public point value of an ECDSA key (to see if it matches a certificate)
# See https://security.stackexchange.com/questions/73127/how-can-you-check-if-a-private-key-and-certificate-match-in-openssl-with-ecdsa
function openssl-check-ecc-key-ppv-and-curve {
	echo "openssl ec -in "${1}" -pubout | shasum -a 256"openssl ec -in key -pubout
	openssl pkey -pubout -in "${1}" | shasum -a 256
}

# Check the modulus of a certificate request
function openssl-check-rsa-csr-modulus {
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

# Scope private do we don't call yarn recursively!
function Private:yarn() {
	$modifiedArgs = @()
	foreach ( $arg in $args ) {
		# yarn broke 'ls'
		if ( $arg -cmatch '^ls$' ) {
			$arg = 'list'
		}
		$modifiedArgs += $arg
		# we're using a monorepo, and only add packages to
		# our workspace if we write them ourselves
		if ( $arg -cmatch 'add' ) {
			$modifiedArgs += '--ignore-workspace-root-check'
		}
	}
	& yarn $modifiedArgs
}
echo 'Mike profile loaded.'
