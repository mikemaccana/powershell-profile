# Install-Module Find-String

# Set-ExecutionPolicy unrestricted

# Install OpenSSH
# Note: do not install chocolatey. Use Install-Package instead.
Add-PathVariable "${env:ProgramFiles}\OpenSSH"

# For working less (except in ISE)
# Install-Package Pscx

# For history with up/down arrows
# Install-Package PSReadLine
Import-Module PSReadLine

# Load posh-git example profile
. 'C:\Users\mike\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

function edit-powershell-profile {
  subl $profile
}

function reload-powershell-profile {
  & $profile
}

# From http://stackoverflow.com/questions/7330187/how-to-find-the-windows-version-from-the-powershell-command-line
function get-windows-build {
  [Environment]::OSVersion
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

function gg {
  & git grep @args
}

function stree {
  & "${env:ProgramFiles(x86)}\Atlassian\SourceTree\SourceTree.exe"
}

#######################################################
# Useful shell aliases
#######################################################

function findfile($name) {
  ls -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach-object {
    $place_path = $_.directory
    echo "${place_path}\${_}"
  }
}

function get-path {
  ($Env:Path).Split(";")
}

#######################################################
# Unixlike commands
#######################################################

function df {
  get-volume
}


function grep($regex, $dir) {
  ls $dir | select-string $regex
}

function which($name) {
  Get-Command $name | Select-Object -ExpandProperty Definition
}

# Should really be name=value like Unix version of export but not a big deal
function export($name, $value) {
  set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
  ps $name -ErrorAction SilentlyContinue | kill
}

function touch($file) {
  "" | Out-File $file -Encoding ASCII
}

# From https://github.com/keithbloom/powershell-profile/blob/master/Microsoft.PowerShell_profile.ps1
function sudo {
  $file, [string]$arguments = $args;
  $psi = new-object System.Diagnostics.ProcessStartInfo $file;
  $psi.Arguments = $arguments;
  $psi.Verb = "runas";
  $psi.WorkingDirectory = get-location;
  [System.Diagnostics.Process]::Start($psi) >> $null
}

# https://technet.microsoft.com/en-us/magazine/hh241048.aspx
$MaximumHistoryCount = 10000

echo 'Mike profile loaded.'
