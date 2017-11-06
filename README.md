# Mike's Powershell Profile

## A powershell profile for *nix users which accidentally became the most starred Powershell profile on github

Heya. I've been using bash for about two decades before getting onto Powershell. I'm a *nix person. I've worked at both Red Hat in the early days, IBM's Dedicated Linux team, and a bunch of other places working with *nix as an sysadmin, SRE, Architect and Tech Lead. I now develop node and TypeScript while trying to make verifying websites ([EV HTTPS](https://certsimple.com/help/what-is-ev-ssl)) less painful at [CertSimple](https://certsimple.com). 

**If you come from a *nix background, and want to use Powershell properly, this is the right place.**

 - Implementations of a bunch of Unix commands
 - The code itself contains useful implementations of common patterns - eg, installing packages, reading the registry, interacting with files and processes. Learning the basic stuff required to make a profile you're happy with is a great way to get comfortable with Powershell. 

The details below are minimal, but the names of most commands make things fairly obvious.

## Prerequisities for any *nix user who wants to use Powershell

### For a decent, tabbed terminal

A future release of Windows 10 will ship with a tabbed terminal (with multi process and everything) but in the meantime, [ConEmu](https://conemu.github.io/) is your best bet. 

[Hyper](https://hyper.is/) may be promising in future but [currently has issues with Powershell](https://github.com/zeit/hyper/issues/1121).

### For 'less' (except in ISE) and a bunch of other useful stuff

Get the [Powershell Community Extensions](https://github.com/Pscx/Pscx). Run:

	Install-Package Pscx

### For history with up/down arrows, other useful vi/emacs keybindings

Run:

	Install-Package PSReadLine

### For 'Remove-ItemSafely' - ie, trashing files from the command line

Run:

	Install-Module -Name Recycle

### For OpenSSH

Run:

	Get-PackageProvider
	Get-PackageSource -Provider chocolatey
	Install-Package -Name openssh

### For OpenSSL

Use [this up to date, secure Windows OpenSSL build](https://indy.fulgan.com/SSL/). 

The popular 'Shining Light' version is an unsigned binary downloaded over an insecure connection - I've offered to help and pay to fix this and the author has no intention of remedying this.

## Minimum Powershell concepts to learn before you rant about how much you hate Powershell

These come with powershell. If you don't know them you're the equivalent of someone who doesn't know `grep` ranting about *nix. 

`select` (also called `select-object`) - select the fields you want on an object

`get-member` - show the properties and methods of an object

`get-itemproperty` - show the properties of registry objects (`ls` only shows children)

`where` - choose items matching some criteria.

## Included Unixlike commands

`unarchive` - 

`findfile` - like  `find -name`

`get-path` - show $PATH as a series of strings.

`prompt` - neat Unix-like prompt

`whois` 

`uptime` - show time since last boot up

`fuser` 

`df` - disk space free

`cut` 

`sed` - replace a regex with a string. 

`sed-recursive`

`grep` - file lines matching a regular expression

`grepv` - aka `grep -v`

`which` -

`export` - sets an environment variable

`pkill`

`pgrep` - 

`touch` - make a blank file

`file` - show a file's type description

`make-link` - Make a symlink

`sudo` -  Note you'll want to quote the command, eg 

	sudo "mkdir 'C:\Program Files\openssl'"

`pstree`

`unzip`

## Included Windows-specific commands

`edit-powershell-profile`

`reload-powershell-profile`

`trash` - move a file or folder to the recycle bun

`change-title` - change the title of the terminal app

`get-windows-build` - get the full WIndows build number

## Included Dev Tools

`subl` - Sublime Text

`explorer` - Windows Explorer

`stree` - SourceTree

`open` - open a file with the program Windows uses for that file type

## Included Git shortcuts

`git-show-ignored`

`git-show-untracked`

`gg` - git grep

## Crypto

### Viewing keys / certs / CSRs 

`openssl-view-certificate`

`openssl-view-csr`

`openssl-view-rsa-key`

`openssl-view-ecc-key`

`openssl-view-pkcs12`

`openssl-convert-p12-to-pem`

### Checking if keys / certs / CSRs match

`openssl-check-rsa-key-modulus`

`openssl-check-rsa-certificate-modulus`

`openssl-check-rsa-csr-modulus`

`openssl-check-ecc-key-ppv-and-curve`

`openssl-check-ecdsa-certificate-ppv-and-curve`

### Tools

`openssl-client`

`openssl-convert-pem-to-p12`

`openssl-crt-to-pem`

`openssl-encrypt`

`openssl-decrypt`

`openssl-key-to-hpkp-pin`

`openssl-key-and-intermediate-to-unified-pem`

`openssl-website-to-hpkp-pin`
