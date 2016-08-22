# Install-Module Find-String

# Install OpenSSH
# Set-ExecutionPolicy unrestricted

# Note: do not install chocolatey. Use Install-Package instead.

# For working less (except in ISE)
# Install-Package Pscx

# For history with up/down arrows
# Install-Package PSReadLine
Import-Module PSReadLine

# Load posh-git example profile
. 'C:\Users\mike\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

# Dev Tools
function subl {
  & "$env:ProgramFiles\Sublime Text 3\subl.exe" @args
}

function edit-powershell-profile {
  subl $profile
}

function grep($regex, $dir) {
  ls $dir | select-string $regex
}

# From http://stackoverflow.com/questions/7330187/how-to-find-the-windows-version-from-the-powershell-command-line
function get-windows-build {
  [Environment]::OSVersion
}

function df {
  get-volume
}

Add-PathVariable "${env:ProgramFiles}\OpenSSH"

function reload-profile {
  & "$profile"
}

function gg {
  & git grep @args
}

function stree {
  & "${env:ProgramFiles(x86)}\Atlassian\SourceTree\SourceTree.exe"
}

# Useful shell aliases

function get-path {
  ($Env:Path).Split(";")
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

function findfile($name) {
  ls -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach-object {
    $place_path = $_.directory
    echo "${place_path}\${_}"
  }
}

# https://technet.microsoft.com/en-us/magazine/hh241048.aspx
$MaximumHistoryCount = 10000

echo 'Mike profile loaded.'
