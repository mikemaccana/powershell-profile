Add-PathVariable "${env:ProgramFiles}\nodejs"

# Add relative node_modules\.bin to PATH - this allows us to easily use local bin files and less things installed globally
Add-PathVariable '.\node_modules\.bin'

# yarn bin folder
Add-PathVariable "${env:ProgramFiles(x86)}\Yarn\bin"
Add-PathVariable "${env:LOCALAPPDATA}\yarn\bin"

# npm bin folder
# Add-PathVariable ${env:APPDATA}\npm

# $env:NODE_PATH = "${env:APPDATA}\npm"

# Scope private do we don't call mocha recursively!
function Private:mocha() {
	mocha --ui tdd --bail --exit
}

# Scope private do we don't call yarn recursively!
function Private:yarn() {
	$modifiedArgs = @()
	foreach ( $arg in $args ) {
		# yarn broke 'ls'
		if ( $arg -cmatch '^ls' ) {
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
