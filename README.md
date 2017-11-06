# Mike's Powershell Profile

Heya. I've been using bash for about two decades before getting onto Powershell. I develop node and TypeScript apps at [https://certsimple.com](CertSimple). 

If you come from a nox background, and want to use Powershell properly, this is the right place.

 - Aliases for a bunch of Unix commands
 - Useful implementations of common patterns - eg, installing packages, reading the registry, interacting with files and processes.

The details below are minimal, but the names of most commands make things fairly obvious.

## Prerequsities

## For a decent, tabbed terminal

A future release of Windows 10 will ship with a tabbed terminal (with multi process and everything) but in the meantime, [ConEmu](https://conemu.github.io/) is your best bet. [Hyper](https://hyper.is/) may be promising in future but [still has issues](https://github.com/zeit/hyper/issues/1121).

### For 'less' (except in ISE) and a bunch of other useful stuff

Get the [Powershell Community Extensions]()

  Install-Package Pscx

## For history with up/down arrows, other useful vi/emacs keybindings

  Install-Package PSReadLine

# For 'Remove-ItemSafely' - ie, trashing files from the command line

  Install-Module -Name Recycle

### For OpenSSH

  Get-PackageProvider
  Get-PackageSource -Provider chocolatey
  Install-Package -Name openssh

### For OpenSSL

Use [this up to date, secure source](https://indy.fulgan.com/SSL/). The popular Shining Light version is an unsigned binary downloaded over an insecure connection - I've offered to help and pay to fix this and the author has no intention of remedying this.   

## Useful Windows-specific commands

`edit-powershell-profile`

`reload-powershell-profile`

`trash` - move a file or folder to the recycle bun

`change-title` - change the title of the terminal app

`get-windows-build` - get the full WIndows build number

`unarchive` - 

`prompt` - neat Unix-like prompt

`open` - open a file with whatever Windows uses

`findfile` 

`get-path`

## Dev Tools

`subl` - Sublime Text

`explorer` - Windows Explorer

`stree` - SourceTree

`git-show-ignored`

`git-show-untracked`

`gg` - git grep

## Unixlike commands

`whois`

`uptime`

`fuser`

`df` - disk space free

`cut` 

`sed` - replace a regex with a string. 

`sed-recursive`

`grep` - file lines matching a regular expression

`grepv` - aka `grep -v`

`which`

`export`

`pkill`

`pgrep` - 

`touch` - make a blank file

`file` - show a file's type description

`make-link` - Make a symlink

`sudo` -  Note you'll want to quote the command, eg 

  sudo "mkdir 'C:\Program Files\openssl'"

`pstree`

`unzip`

## Crypto

`openssl-check-ecc-key-ppv-and-curve`

`openssl-encrypt`

`openssl-check-ecdsa-certificate-ppv-and-curve`

`openssl-key-and-intermediate-to-unified-pem`

`openssl-check-rsa-certificate-modulus`

`openssl-key-to-hpkp-pin`

`openssl-check-rsa-csr-modulus`

`openssl-view-certificate`

`openssl-check-rsa-key-modulus`

`openssl-view-csr`

`openssl-client`

`openssl-view-ecc-key`

`openssl-convert-p12-to-pem`

`openssl-view-pkcs12`

`openssl-convert-pem-to-p12`

`openssl-view-rsa-key`

`openssl-crt-to-pem`

`openssl-website-to-hpkp-pin`

`openssl-decrypt`