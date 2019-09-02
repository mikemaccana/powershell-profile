# RethinkDB and Python (needed for the Python rethinkdb dump tool)
Add-PathVariable "${env:ProgramFiles}\rethinkdb"
Add-PathVariable "${env:ProgramFiles}\Python"
# pip is in the scripts dir
Add-PathVariable "${env:ProgramFiles}\Python\Scripts"

# mongoDB
Add-PathVariable 'C:\Program Files\MongoDB\Server\4.0\bin'

# git
Add-PathVariable "${env:ProgramFiles}/git/bin"
# To use git supplied by SourceTree instead of the 'git for Windows' version
# Add-PathVariable "${env:LOCALAPPDATA}\Atlassian\SourceTree\git_local\bin"
Add-PathVariable "${env:ProgramFiles}\Git\bin"

# vscode
Add-PathVariable "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\bin" 

# Python (also needed for the Python rethinkdb dump tool)
Add-PathVariable "${env:ProgramFiles}\Python"
# pip is in the scripts dir
Add-PathVariable "${env:ProgramFiles}\Python\Scripts"

# Tab completion for git (also modified prompt, which I dislike, so disabled)
# Install-Module posh-git

# Load posh-git example profile
# . 'C:\Users\mike\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

function gg {
	# Replace 'file:linenumber:content' with 'file:linenumber content'
	# so you can just click the file:linenumber and go straight there.
	& git grep -n -i @args | foreach-object { $_ -replace '(\d+):','$1 ' }  
}

function get-git-ignored {
	git ls-files . --ignored --exclude-standard --others
}

function get-git-untracked {
	git ls-files . --exclude-standard --others
}

# For git rebasing
# --wait required, see https://github.com/Microsoft/vscode/issues/23219 
$env:EDITOR = 'code --wait'

# Kinda like $EDITOR in nix
# TODO: check out edit-file from PSCX
# You may prefer eg 'subl' or 'code' or whatever else
function edit {
	& "code" -g @args
}

function fork {
	# Fork requires an absolute path https://github.com/ForkIssues/TrackerWin/issues/416#issuecomment-527067604
	$absolutePath = resolve-path .
	& ${env:LOCALAPPDATA}\Fork\Fork.exe $absolutePath
}

# I used to run Sublime so occasionally my fingers type it
function subl {
	# 	& "$env:ProgramFiles\Sublime Text 3\subl.exe" @args
	write-output "Type 'edit' instead"
}

