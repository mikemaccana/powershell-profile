# HandleToolsV1.psm1 is a set of Powershell tools to find and remove stuck file handles.
#
# Function list:
#
# New-Handle
# Get-Handle
# Close-Handle
# 
# @Author:	xXBlu3f1r3Xx
# @Date:	July 25th, 2015
# @PSVers:	2.0+
#
# @About:	These functions have been trimmed down to generalize them for different environments. I originally
# created the tools to work within my company's Citrix server environment. I highly recommend including a 
# function to populate a list of servers, or computers. Included in my work toolset is the function,
# Get-ServerList, which populates an array of servers for my other functions, if specified with a switch
# parameter. I have used these functions to create a number of relatively short scripts for easily clearing stuck
# file handles. In this version you must call Close-Handle within an Invoke-Command script block. It can fairly 
# easily be modified to run remotely as Get-Handle does and a future release may incorporate that idea. 
# I left it out to better suite my current needs. The handle tools also require that Handle.exe from 
# SysInternals as well as this toolset be downloaded to the machines you plan on running them on. The file paths are
# currently set to the C drive so make sure to edit the location of your downloads before running.

<#
.SYNOPSIS
   Creates a Handle object for storing each handle.
.DESCRIPTION
   Creates a custom Powershell object storing all the properties found when parsing
   the handle.exe output.
.EXAMPLE
   New-Handle -props ("a", 3, "b", "c", "d", "e", "f")
   This command will create a handle with the seven properties of a handle. Note that the second
   property (Process ID) is an integer while the rest are all strings, including the Handle ID (property 4),
   which will be in hexadecimal format.
.INPUTS
   An array of seven values where the second is an integer and the others are strings.
.LINK
   Get-Handle
   Close-Handle
.NOTES
   This function is intended for use with Get-Handle to store the parsed output of Handle.exe. 
   It is not intended as an independent function. 
   
   @Author: xXBlu3f1r3Xx
   @LEDate: July 25th, 2015
   @PSVers: 2.0+
#>
function New-Handle {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param (
        # Array of properties to create this object
        [Parameter(Mandatory=$true)]
        [alias("p")]
        [Object[]]
        $props
    )
    $h = New-Object -TypeName PSObject
    Add-Member -InputObject $h -MemberType NoteProperty -Name ProcessName -Value $props[0]
    Add-Member -InputObject $h -MemberType NoteProperty -Name ProcessId -Value $props[1]
    Add-Member -InputObject $h -MemberType NoteProperty -Name User -Value $props[2]
    Add-Member -InputObject $h -MemberType NoteProperty -Name HandleId -Value $props[3]
    Add-Member -InputObject $h -MemberType NoteProperty -Name HandleType -Value $props[4]
    Add-Member -InputObject $h -MemberType NoteProperty -Name Rights -Value $props[5]
    Add-Member -InputObject $h -MemberType NoteProperty -Name Name -Value $props[6]

    $h
}

<#
.SYNOPSIS
   Searches for all handles currently open by the provided user.
.DESCRIPTION
   Uses Handle.exe created by Mark Russinovich at SysInternals.
   Uses the custom Handle class to store the information.
.EXAMPLE
   Get-Handle -username test
   This command will output all handles found for the user "test".
.EXAMPLE
   Get-Handle -user "test user"
   This command will output all handles found for the user "test user". Quotes are only required if the
   username contains a space.
.EXAMPLE
   Get-Handle -user test -servers (comp1, comp2)
   This command will output all handles found for the user "test" on the machines named "comp1"
   and "comp2".
.INPUTS
   A required <String> and an optional <String[]>.
.LINK
   New-Handle
   Close-Handle
.NOTES
   This function will parse the output of Handle.exe, extracting the seven handle properties for each
   handle found under the given username. It will call New-Handle to store each one found and will output an
   array of these custom handle objects.
   
   @Author: xXBlu3f1r3Xx
   @LEDate: July 25th, 2015
   @PSVers: 2.0+
#>
function Get-Handle {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    Param (
        # Username to search handles for
        [Parameter(Mandatory=$true,
                   HelpMessage="Enter a username")]
        [alias("u")]
        [alias("user")]
        [string]
        $username,
		
		# Server(s) to query. If not specified the function will run on the machine calling it.
		[Parameter()]
		[alias("server")]
		[alias("v")]
		[string[]]
		$servers
    )
	BEGIN {
		# Populate serverList if servers weren't passed to the function
		$serverList = @()
		if (!($servers)) {
			$serverList = $env:computername		# default to the machine running this function
		}
		else {
			$serverList = $servers
		}
		
		# I am currently researching quicker methods of finding handles.
		# I may end up making my own compiled program instead of relying on Handle.exe
		Write-Host "Beginning handle search..." -f yellow -b black
		Write-Host "Expect this to take 20-90 seconds, dependent on the available resources." -f yellow -b black
		Write-Host " "

		$foundHandles = @()
		$sw = [Diagnostics.Stopwatch]::StartNew()		# To test the run time of this loop
	}
	PROCESS {
		$foundHandles += Invoke-Command -ComputerName $serverList -ScriptBlock {
			$username = $args[0]
			Import-Module "C:\HandleToolsV1.psm1"
		
			# Regular expressions to match the lines to
			$regexp1 = "^([^ ]+)\spid:\s(\d+)\s([\s*\S*]+)$"
			$regexp2 = "^([(0-9)*(A-F)*]+):\s([^ ]+)\s{2}(\([[RWD-]{3}]?\))\s*([\s*\S*]*$username[\s*\S*]*)$"
			$regexp3 = "^([(0-9)*(A-F)*]+):\s([^ ]+)\s*([\s*\S*]*$username[\s*\S*]*)$"
		
			$PSHandles = New-Object System.Collections.Generic.List[PSCustomObject]
			$procInfo = ("", 0, "", "", "", "", "")		# passed as parameter to Create-Handle
			$handles = & "C:\handle.exe" -a -accepteula -u
			
			for ($i = 5; $i -lt $handles.Length; $i++) {
				$line = [string]$handles[$i].trim()
			
				# Indicates start of new process
				if ($line.SubString(0, 1) -eq "-") {
					$i++		# Move to the next line
					$line = [string]$handles[$i].trim()
					# Match to regular expression for this line and extract info
					$valid1 = $line -match $regexp1
					if ($valid1) {
						$procInfo[0] = [String]$Matches[1]
						$procInfo[1] = [int]$Matches[2]
						$procInfo[2] = [String]$Matches[3]
					}
				
					# Prep for first file handle from this process
					$i++
					$line = [string]$handles[$i].trim()
				}
			
				# Match to regular expression for the file handle lines and extract info
				$valid2 = $line -match $regexp2
				
				if ($valid2) {		# If it matches regexp2 it is a File and has the access property
					$procInfo[3] = [String]$Matches[1]
					$procInfo[4] = [String]$Matches[2]
					$procInfo[5] = [String]$Matches[3]
					$procInfo[6] = [String]$Matches[4]
				}
				else {	
					$valid3 = $line -match $regexp3
					if ($valid3) {		# If it matches regexp3 it is some type other than File and skips the access property
						$procInfo[3] = [String]$Matches[1]
						$procInfo[4] = [String]$Matches[2]
						$procInfo[5] = ""
						$procInfo[6] = [String]$Matches[3]
					}
					else {		# skip storing this one if it doesn't match the regex
						Clear-Variable Matches
						continue		
					}
				}

				Clear-Variable Matches

				$tempHandle = New-Handle -props $procInfo
				$PSHandles.add($tempHandle)	
			}
			
			Return $PSHandles
		} -ArgumentList $username
	}
	END {
		$sw.Stop()
		$ts = $sw.Elapsed
		$elapsedTime = "$($ts.minutes):$($ts.seconds).$($ts.milliseconds)"
		Write-Host "Elapsed time (minutes:seconds.milliseconds) -> " -nonewline; Write-Host $elapsedTime -f yellow -b black
		Write-Host " "

		# Return search results
		$foundHandles | Sort-Object -Property PSComputerName, ProcessId
	}
}

<#
.SYNOPSIS
   Closes open file handles..
.DESCRIPTION
   Closes handles by using the process and handle IDs.
   Meant to be used in conjuction with Get-Handle.
   Uses Handle.exe created by Mark Russinovich at SysInternals.
.EXAMPLE
   Close-Handle -handleId 6F -processId 2364
   This command will close the handle with hid 6F and pid 2364.
.EXAMPLE
   Close-Handle -h "5D" -p 1234
   This command will close the handle with hid 6F and pid 2364.
.EXAMPLE
   Close-Handle "47" 865
   This command will close the handle with hid 47 and pid 865.
.EXAMPLE
   Get-Handle test | Close-Handle
   This command will retrieve the open file handles of user "test" and close all that it can.
.INPUTS
   Either an array of custom handle objects or it will accept an integer array <int[]> (process Id's) and
   a string array <String[]> (handle Id's) which are of the same size.
	
   An array of custom handle objects can be piped to this function as well.
.LINK
   New-Handle
   Get-Handle
.NOTES
   This function will close the handles specified by the process Id's and handle Id's provided to it. 
   It makes use of Handle.exe to close them. Note that system handles <pid 4> cannot be closed this way.
   Closing lsass.exe handles can be safely done with this tool whereas closing them by process Id alone has
   undesirable results. This should not be used on users who are currently logged on to the machine.
   
   @Author: xXBlu3f1r3Xx
   @LEDate: July 25th, 2015
   @PSVers: 2.0+
#>
function Close-Handle {
    [CmdletBinding()]
    Param (
		# For passing an array of Handles to the function...
		[Parameter(ValueFromPipeline=$true)]
		[PSCustomObject[]]
		$handles,
	
        # Handle ID to close (in hexadecimal format)
        [Parameter(Mandatory=$false,
                   HelpMessage="Enter a Handle ID number (Hexadecimal)")]
        [alias("h")]
        [string[]]
        $handleId,

        # Process ID. Required to close the chosen handle
        [Parameter(Mandatory=$false,
                   HelpMessage="Enter a Process ID number")]
        [alias("p")]
        [int[]]
        $processId
    )
	BEGIN {
		# Verify there is an equal number of handle and process ID's
		if ($handleId.Length -ne $processId.Length) {
			Write-Host "Number of Handle ID's and Process ID's must match!" -f red -b black
			Break
		}
		
		$total = 0
		if ($handles) {
			$total += $handles.Length
		}
		else {
			$total += $handleId.Length
		}
		
		Write-Host " "
		Write-Host "Attempting to close " -f yellow -b black -nonewline
		if ($total -ne 0) {
			Write-Host "$total " -f red -b black -nonewline
		}
		else {
			Write-Host "all piped " -f red -b black -nonewline
		}
		Write-Host "handle(s). Continue? (Y/N)" -f yellow -b black -nonewline; $cont = Read-Host " "
		if ($cont -ne "y") {
			Write-Host "Exiting..." -f yellow -b black
			Break
		}
		Write-Host " "
		Write-Host "Beginning closure process..." -f yellow -b black
		Write-Host " "
		$closedCount = 0
	}
	PROCESS {
		# Used when piping handles or passing an array of handles
		if (!$handleId -or !$processId) {
			# Actually close all the handles specified
			foreach ($h in $handles) {
				if ($h.processId -ne 4) {			# Exclude system processes
					& "C:\handle.exe" -accepteula -c $h.handleId -p $h.processId -y | Out-Null
					$closedCount++
				}
				else {
					Write-Host "Unable to close system process <PID 4>, skipping..." -f magenta -b black
				}
			}
		}
		else {	# Used when passing an array (or individual) handle/process IDs
			# Actually close all the handles specified
			for ($j = 0; $j -lt $handleId.Length; $j++) {
				if ($processId[$j] -ne 4) {			# Exclude system processes
					& "C:\handle.exe" -accepteula -c $handleId[$j] -p $processId[$j] -y | Out-Null
					$closedCount++
				}
				else {
					Write-Host "Unable to close system process <PID 4>, skipping..."
				}
			}
		}
	}
	END{
		Write-Host " "
		Write-Host "Attempted closure of " -f yellow -b black -nonewline
		Write-Host "$closedCount" -f green -b black -nonewline
		Write-Host " handles." -f yellow -b black
		Write-Host " "
	}
}