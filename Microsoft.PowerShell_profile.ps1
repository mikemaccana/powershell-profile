# Install-Module Find-String

# Set-ExecutionPolicy unrestricted

Add-PathVariable "${env:ProgramFiles}\OpenSSH"
Add-PathVariable "${env:ProgramFiles}\OpenSSL\bin"
Add-PathVariable "${env:ProgramFiles}\rethinkdb"
Add-PathVariable "${env:ProgramFiles}\7-Zip"
Add-PathVariable "${env:ProgramFiles}\wtrace"
Add-PathVariable "${env:ProgramFiles}\nodejs"
Add-PathVariable "${env:ProgramFiles(x86)}\Yarn\bin"

# Add relative node_modules\.bin to PATH - this keeps updating as we `cd`
Add-PathVariable '.\node_modules\.bin'

# Various bits for openssl
# $env:OPENSSL_CONF = "${env:ProgramFiles}\OpenSSL\openssl.cnf"
# $env:RANDFILE="${env:LOCALAPPDATA}\openssl.rnd"

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
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null

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
# You may prefer eg 'subl' or 'code' or whatever else
# --disable-gpu needed for https://github.com/Microsoft/vscode/issues/13612
function edit {
	& "code-insiders" --disable-gpu -g @args
}

# For git rebasing
# --wait required, see https://github.com/Microsoft/vscode/issues/23219 
$env:EDITOR = 'code-insiders --wait'

function subl {
	write-output "Type 'edit' instead"
}

function reboot {
	shutdown /r /t 0
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

function disable-windows-search {
	Set-Service wsearch -StartupType disabled
	stop-service wsearch
}

# http://mohundro.com/blog/2009/03/31/quickly-extract-files-with-powershell/
# and https://stackoverflow.com/questions/1359793/programmatically-extract-tar-gz-in-a-single-step-on-windows-with-7zip
function extract-archive([string]$file, [string]$outputDir = '') {
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

function findfile($name) {
	get-childitem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach-object {
		$place_path = $_.directory
		write-output "${place_path}\${_}"
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
	write-host $Child.FullName | select-object '*'
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

# function subl {
# 	& "$env:ProgramFiles\Sublime Text 3\subl.exe" @args
# }

function explorer {
	explorer.exe .
}

function settings {
	start ms-setttings:
}

function stree {
	$SourceTreeFolder =  get-childitem ("${env:LOCALAPPDATA}" + "\SourceTree\app*") | Select-Object -first 1
	& $SourceTreeFolder/SourceTree.exe -f .
}




#######################################################
# Unixlike commands
#######################################################

# http://stackoverflow.com/questions/39148304/fuser-equivalent-in-powershell/39148540#39148540
function fuser($relativeFile){
	$file = Resolve-Path $relativeFile
	write-output "Looking for processes using $file"
	foreach-object ( $Process in (Get-Process)) {
		foreach-object ( $Module in $Process.Modules) {
			if ( $Module.FileName -like "$file*" ) {
				$Process | select-object id, path
			}
		}
	}
}

# https://gallery.technet.microsoft.com/WHOIS-PowerShell-Function-ed69fde6
Unblock-File $home\scripts\whois.ps1
. $home\scripts\whois.ps1


function uptime {
	Get-CimInstance Win32_OperatingSystem | select-object csname, @{LABEL='LastBootUpTime';
	EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

function get-serial-number {
  Get-CimInstance -ClassName Win32_Bios | select-object serialnumber
}

function df {
	get-volume
}
function unzip {
	extract-archive
}

function sed($file, $find, $replace){
	(Get-Content $file).replace("$find", $replace) | Set-Content $file
}
function sed-recursive($filePattern, $find, $replace) {
	$files = get-childitem . "$filePattern" -rec # -Exclude
	write-output $files
	foreach-object ($file in $files) {
		(Get-Content $file.PSPath) |
		Foreach-Object { $_ -replace "$find", "$replace" } |
		Set-Content $file.PSPath
	}
}
function grep($regex, $dir) {
	if ( $dir ) {
		get-childitem $dir | select-object-string $regex
		return
	}
	$input | select-object-string $regex
}
function grepv($regex) {
	$input | ? { !$_.Contains($regex) }
}

function show-links($dir){
	get-childitem $dir | ?{$_.LinkType} | select-object FullName,LinkType,Target
}
function which($name) {
	Get-Command $name | Select-Object -ExpandProperty Definition
}
function cut(){
	foreach-object ($part in $input) {
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
	New-Item $file -type file
}

# From https://stackoverflow.com/questions/894430/creating-hard-and-soft-links-using-powershell
function ln($target, $link) {
	New-Item -ItemType SymbolicLink -Path $link -Value $target
}

function make-link {
	ln
}

function Private:file($file) {
	$extension = (Get-Item $file).Extension
	$fileType = (gp "Registry::HKEY_Classes_root\$extension")."(default)"
	$description =  (gp "Registry::HKEY_Classes_root\$fileType")."(default)"
	write-output $description
}

# From https://github.com/Pscx/Pscx
function sudo(){
	Invoke-Elevated @args
}

# https://gist.github.com/aroben/5542538
function pstree {
	$ProcessesById = @{}
	foreach-object ($Process in (Get-WMIObject -Class Win32_Process)) {
		$ProcessesById[$Process.ProcessId] = $Process
	}

	$ProcessesWithoutParents = @()
	$ProcessesByParent = @{}
	foreach-object ($Pair in $ProcessesById.GetEnumerator()) {
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
		foreach-object ($Child in ($ProcessesByParent[$ProcessId] | Sort-Object CreationDate)) {
			Show-ProcessTree $Child.ProcessId ($IndentLevel + 4)
		}
	}

	Write-Output ("{0,6} {1}" -f "PID", "Command Line")
	Write-Output ("{0,6} {1}" -f "---", "------------")

	foreach-object ($Process in ($ProcessesWithoutParents | Sort-Object CreationDate)) {
		Show-ProcessTree $Process.ProcessId 0
	}
}

# From https://certsimple.com/blog/openssl-shortcuts
function write-iew-certificate ($file) {
	write-output "openssl x509 -text -noout -in $file"
	openssl x509 -text -noout -in $file
}

function write-iew-csr ($file) {
	write-output "openssl req -text -noout -verify -in $file"
	openssl req -text -noout -verify -in $file
}

function write-iew-rsa-key ($file) {
	write-output openssl rsa -check -in $file
	openssl rsa -check -in $file
}

function write-iew-rsa-key ($file) {
	write-output "openssl rsa -check -in $file"
	openssl rsa -check -in $file
}

function write-iew-ecc-key ($file) {
	write-output "openssl ec -check -in $file"
	openssl ec -check -in $file
}

function write-iew-pkcs12 ($file) {
	write-output "openssl pkcs12 -info -in $file"
	openssl pkcs12 -info -in $file
}

# Connecting to a server (Ctrl C exits)
function openssl-client ($server) {
	write-output "openssl s_client -status -connect $server:443"
	openssl s_client -status -connect $server:443
}

# Convert PEM private key, PEM certificate and PEM CA certificate (used by nginx, Apache, and other openssl apps)
# to a PKCS12 file (typically for use with Windows or Tomcat)
function openssl-convert-pem-to-p12 ($key, $cert, $cacert, $output) {
	write-output "openssl pkcs12 -export -inkey $key -in $cert -certfile $cacert -out $output"
	openssl pkcs12 -export -inkey $key -in $cert -certfile $cacert -out $output
}

# Convert a PKCS12 file to PEM
function openssl-convert-p12-to-pem ($p12file, $pem) {
	write-output "openssl pkcs12 -nodes -in $p12file -out $pemfile"
	openssl pkcs12 -nodes -in $p12file -out $pemfile
}

# Convert a crt to a pem file
function openssl-crt-to-pem($crtfile) {
	write-output "openssl x509 -in $crtfile -out $basename.pem -outform PEM"
	openssl x509 -in $crtfile -out $basename.pem -outform PEM
}

# Check the modulus of an RSA certificate (to see if it matches a key)
function openssl-check-rsa-certificate-modulus {
	write-output "openssl x509 -noout -modulus -in "${1}" | shasum -a 256"
	openssl x509 -noout -modulus -in "${1}" | shasum -a 256
}

# Check the public point value of an ECDSA certificate (to see if it matches a key)
# See https://security.stackexchange.com/questions/73127/how-can-you-check-if-a-private-key-and-certificate-match-in-openssl-with-ecdsa
function openssl-check-ecdsa-certificate-ppv-and-curve {
	write-output "openssl x509 -in "${1}" -pubkey | shasum -a 256"
	openssl x509 -noout -pubkey -in "${1}" | shasum -a 256
}

# Check the modulus of an RSA key (to see if it matches a certificate)
function openssl-check-rsa-key-modulus {
	write-output "openssl rsa -noout -modulus -in "${1}" | shasum -a 256"
	openssl rsa -noout -modulus -in "${1}" | shasum -a 256
}

# Check the public point value of an ECDSA key (to see if it matches a certificate)
# See https://security.stackexchange.com/questions/73127/how-can-you-check-if-a-private-key-and-certificate-match-in-openssl-with-ecdsa
function openssl-check-ecc-key-ppv-and-curve {
	write-output "openssl ec -in "${1}" -pubout | shasum -a 256"openssl ec -in key -pubout
	openssl pkey -pubout -in "${1}" | shasum -a 256
}

# Check the modulus of a certificate request
function openssl-check-rsa-csr-modulus {
	write-output openssl req -noout -modulus -in "${1}" | shasum -a 256
	openssl req -noout -modulus -in "${1}" | shasum -a 256
}

# Encrypt a file (because zip crypto isn't secure)
function openssl-encrypt () {
	write-output openssl aes-256-cbc -in "${1}" -out "${2}"
	openssl aes-256-cbc -in "${1}" -out "${2}"
}

# Decrypt a file
function openssl-decrypt () {
	write-output aes-256-cbc -d -in "${1}" -out "${2}"
	openssl aes-256-cbc -d -in "${1}" -out "${2}"
}

# For setting up public key pinning
function openssl-key-to-hpkp-pin() {
	write-output openssl rsa -in "${1}" -outform der -pubout | openssl dgst -sha256 -binary | openssl enc -base64
	openssl rsa -in "${1}" -outform der -pubout | openssl dgst -sha256 -binary | openssl enc -base64
}

# For setting up public key pinning (directly from the site)
function openssl-website-to-hpkp-pin() {
	write-output openssl s_client -connect "${1}":443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
	openssl s_client -connect "${1}":443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
}

# Scope private do we don't call yarn recursively!
function Private:yarn() {
	$modifiedArgs = @()
	foreach-object ( $arg in $args ) {
		# yarn broke 'get-childitem'
		if ( $arg -cmatch '^get-childitem$' ) {
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

cd ~/Documents

write-output 'Mike profile loaded.'
