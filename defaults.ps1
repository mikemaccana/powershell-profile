# Proper history etc
Import-Module PSReadLine

# Produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

# https://technet.microsoft.com/en-us/magazine/hh241048.aspx
$MaximumHistoryCount = 10000;

Set-Alias trash Remove-ItemSafely

function open($file) {
  invoke-item $file
}

function explorer {
  explorer.exe .
}

function edge {
  # Old Edge
  # start microsoft-edge:
  #
  # New Chromioum Edge
  & "${env:ProgramFiles(x86)}\Microsoft\Edge Dev\Application\msedge.exe"
}
function settings {
  start-process ms-setttings:
}

# Oddly, Powershell doesn't have an inbuilt variable for the documents directory. So let's make one:
# From https://stackoverflow.com/questions/3492920/is-there-a-system-defined-environment-variable-for-documents-directory
$env:DOCUMENTS = [Environment]::GetFolderPath("mydocuments")

# PS comes preset with 'HKLM' and 'HKCU' drives but is missing HKCR 
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null

# Truncate homedir to ~
function limit-HomeDirectory($Path) {
  $Path.Replace("$home", "~")
}

# Must be called 'prompt' to be used by pwsh 
# https://github.com/gummesson/kapow/blob/master/themes/bashlet.ps1
function prompt {
  $realLASTEXITCODE = $LASTEXITCODE
  Write-Host $(limit-HomeDirectory("$pwd")) -ForegroundColor Yellow -NoNewline
  Write-Host " $" -NoNewline
  $global:LASTEXITCODE = $realLASTEXITCODE
  Return " "
}

# Make $lastObject save the last object output
# From http://get-powershell.com/post/2008/06/25/Stuffing-the-output-of-the-last-command-into-an-automatic-variable.aspx
function out-default {
  $input | Tee-Object -var global:lastobject | Microsoft.PowerShell.Core\out-default
}

# If you prefer oh-my-posh
# Import-Module posh-git
# Import-Module oh-my-posh

function rename-extension($newExtension){
  Rename-Item -NewName { [System.IO.Path]::ChangeExtension($_.Name, $newExtension) }
}