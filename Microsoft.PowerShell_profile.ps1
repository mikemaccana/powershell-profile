# Install-Module Find-String

# Set-ExecutionPolicy unrestricted

# Install OpenSSH
# Note: do not install chocolatey. Use Install-Package instead.
# Get-PackageProvider
# Get-PackageSource -Provider chocolatey
# Install-Package -Name openssh
Add-PathVariable "${env:ProgramFiles}\OpenSSH"

# For working less (except in ISE)
# Install-Package Pscx

# For history with up/down arrows
# Install-Package PSReadLine
Import-Module PSReadLine

# Tab completion for git
# Install-Module posh-git
# Load posh-git example profile
# . 'C:\Users\mike\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

# https://gallery.technet.microsoft.com/scriptcenter/Get-NetworkStatistics-66057d71
. 'C:\Users\mike\powershell\Get-NetworkStatistics.ps1'

function uptime {
  Get-WmiObject win32_operatingsystem | select csname, @{LABEL=’LastBootUpTime’;
  EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}

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
  & git grep -i @args
}

# See https://jira.atlassian.com/browse/SRCTREEWIN-394 for some limits here
function stree {
  & "${env:ProgramFiles(x86)}\Atlassian\SourceTree\SourceTree.exe" -f $pwd
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

#######################################################
# Unixlike commands
#######################################################

function df {
  get-volume
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

# From https://github.com/keithbloom/powershell-profile/blob/master/Microsoft.PowerShell_profile.ps1
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
# https://technet.microsoft.com/en-us/magazine/hh241048.aspx
$MaximumHistoryCount = 10000

# http://stackoverflow.com/questions/39221953/can-i-make-powershell-tab-complete-show-me-all-options-rather-than-picking-a-sp
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

echo 'Mike profile loaded.'
