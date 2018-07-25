# Mike's Powershell Profile (and how to set up Windows console if you've been using *nix for 20 years)

Heya. I've been using bash for about two decades before getting onto Powershell. I'm a *nix person. I've worked at both Red Hat in the early days, IBM's dedicated Linux team, and a bunch of other places working with *nix as an sysadmin, SRE, Architect, and CTO. I now develop node and TypeScript while trying to make [verifying companies for EV HTTPS](https://certsimple.com/help/what-is-ev-ssl) less painful at [CertSimple](https://certsimple.com). 

**If you come from a Linux or Unix background, and want to use Powershell properly, this is the right place.**

 - Implementations of a bunch of Unix commands
 - The profile code itself contains useful implementations of common patterns - eg, installing packages, reading the registry, interacting with files and processes. Learning the basic stuff required to make a profile you're happy with is a great way to get comfortable with Powershell. 

The details below are minimal, but the names of most commands make things fairly obvious.

## Prerequisities for any *nix user who wants to use Powershell

This is what I install on any Windows 10 box.

### Powershell 6 (also called Powershell Core 6)

[Powershell Core 6](https://docs.microsoft.com/en-gb/powershell/scripting/setup/Installing-PowerShell-Core-on-Windows?view=powershell-6) has a number of useful bits, but the main thing is it starts way faster than Powershell 5, so there's less lag when you open a new tab.

### For a decent, tabbed terminal

Future builds of Windows will have Sets - which provides a tabbed terminal out of the box when you start Powershell Core 6 (and probably other apps but I don't care). 

<img src="windows-console.png"/>

In the meantime you can use [Groupy](https://www.stardock.com/products/groupy/) (paid, 30 day free trial) to do the same thing as Sets. This is currently my recommendation for a terminal on Windows - Microsoft's terminal works the best with the fewest bugs.

Otherwise [ConEmu](https://conemu.github.io/) is your best bet (it has some contrast issues which make it hard to see the open tab, and is hampered by its author's desire for Windows XP support). [cmder](http://cmder.net/)'s website makes it seems like it's a new terminal, but cmder is just ConEmu and some additional things you may already have installed.

#### Terminal apps that don't yet work on Windows

The apps below all plan on having WIndows support ion future, but don't yet properly work at the time of writing. There are links to the tracking bugs below.

[Hyper](https://hyper.is/) [currently has issues with Ctrl C for Powershell](https://github.com/zeit/hyper/issues/1121). 

[Upterm](https://github.com/railsware/upterm) [doesn't yet work on Windows](https://github.com/railsware/upterm/issues/800
)

[Terminus](https://eugeny.github.io/terminus/) [can't start Powershell 6 yet](https://github.com/Eugeny/terminus/issues/291)

### For 'less' and a bunch of other useful stuff

Get the [Powershell Community Extensions](https://github.com/Pscx/Pscx). Run:

	Install-Module Pscx -Scope CurrentUser

### For history with up/down arrows, other useful vi/emacs keybindings

PSReadLine is included in Powershell Core 6. For older Powershells, run:

	Install-Package PSReadLine

### For 'Remove-ItemSafely' - ie, trashing files from the command line

Run:

	Install-Module -Name Recycle -Scope CurrentUser

### To import your iterm colors

You can import and tweak an `.itermcolors` file using [terminal.sexy](https://terminal.sexy) 

[ColorTool](https://blogs.msdn.microsoft.com/commandline/2017/08/11/introducing-the-windows-console-colortool/) can be used to apply a `.itermcolors` file to the windows console (which determines coloring for powershell, bash, and cmd). [Download ColorTool from Microsoft's GitHub](https://github.com/Microsoft/console/tree/master/tools/ColorTool).

Run:

	./colortool -b color-scheme.itermcolors

### For OpenSSH

OpenSSH now comes with Windows. **Settings** -> **Manage Optional Features** -> **OpenSSH client**. 

### For OpenSSL (if you need it)

Personally I use OpenSSL for viewing private keys, pubkeys, certificates, and other TLS/PKI work. Unless you do the same you probably don't need OpenSSL. 

The Windows version of OpenSSH uses Windows CryptoAPI rather than OpenSSL, so if you want to add OpenSSL, you'll have to install it.

Use [this up to date, secure Windows OpenSSL build](https://indy.fulgan.com/SSL/). 

The popular 'Shining Light' Windows OpenSSL is an unsigned binary downloaded over an insecure connection - I've offered to help fix this and the author has no intention of remedying the situation.

### For host, dig and other DNS tools

Download [Bind 9 for Windows](https://www.isc.org/downloads/). Extract the zip and run `BINDinstall.exe` as Administrator. 

## Minimum Powershell concepts to learn before you rant about how much you hate Powershell

These come with powershell. If you don't know them you're the equivalent of someone who doesn't know `grep` ranting about how "Unix is like DOS". Might be painful to hear but it's true. 

`select` (also called `select-object`) - select the fields you want on an object

`get-member` - show the properties and methods of an object

`get-itemproperty` - show the properties of registry objects (`ls` only shows children)

`where` (also called `where-object`) - choose items matching some criteria.

## Included commands

### Stuff that should be there out of the box

`edit` - edits a file (using VSCode insiders, but modify as you please)

`open` - open a file using associated app

`settings` - the Windows Settings app

`explorer` - file explorer

### File management

`expand-archive` - also called `unzip`

`find-file`

`show-links`

## OS management

`reboot`

`get-windows-build` 

`disable-windows-search` - Windows Search Indexer kills interactive IO and hasn't been fixed for 15 years. 

`get-serial-number`

### Unix like commands

`grep`

`grepv`

`df`

`sed`

`edit-recursive`

`stree`

`fuser`

`pkill`

`pgrep`

`touch`

`file`

`sudo` - note command after `sudo` must be quoted

`uptime`

`cut`

`export`

`ln`

`pstree`

`which`

`find`

## Powershell stuff


`prompt` - a nice Unixlike prompt with ~ style truncation for the home directory

`edit-powershell-profile`

`update-powershell-profile` - re-run your profile

`set-title` - set the window title

`get-path` - get the PATH, one item per line

## Development


`get-git-ignored`

`get-git-untracked`

`gg` - A `git grep` Alias

`yarn` - Yarn wrapper with `yarn ls` re-added, since I hate typing `yarn list`

### Crypto


`read-certificate`

`read-csr`

`read-rsa-key`

`read-rsa-key`

`read-ecc-key`

`read-pkcs12`

`test-openssl-client`

`convert-pem-to-p12`

`convert-p12-to-pem`

`convert-crt-to-pem`

`show-rsa-certificate-modulus`

`show-ecdsa-certificate-ppv-and-curve`

`show-rsa-key-modulus`

`show-ecc-key-ppv-and-curve`

`show-rsa-csr-modulus`

`protect-file`

`unprotect-file`

`convert-key-to-hpkp-pin`

`convert-website-to-hpkp-pin`
