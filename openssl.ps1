Add-PathVariable "${env:ProgramFiles}\OpenSSL"

# See https://stackoverflow.com/questions/14459078/unable-to-load-config-info-from-usr-local-ssl-openssl-cnf
$env:OPENSSL_CONF = "${env:ProgramFiles}\OpenSSL\openssl.cnf"

# $env:RANDFILE="${env:LOCALAPPDATA}\openssl.rnd"

# From https://certsimple.com/blog/openssl-shortcuts
function read-certificate ($file) {
	write-output "openssl x509 -text -noout -in $file"
	openssl x509 -text -noout -in $file
}

function read-csr ($file) {
	write-output "openssl req -text -noout -verify -in $file"
	openssl req -text -noout -verify -in $file
}

function read-rsa-key ($file) {
	write-output openssl rsa -check -in $file
	openssl rsa -check -in $file
}

function read-rsa-key ($file) {
	write-output "openssl rsa -check -in $file"
	openssl rsa -check -in $file
}

function read-ecc-key ($file) {
	write-output "openssl ec -check -in $file"
	openssl ec -check -in $file
}

function read-pkcs12 ($file) {
	write-output "openssl pkcs12 -info -in $file"
	openssl pkcs12 -info -in $file
}

# Connecting to a server (Ctrl C exits)
function test-openssl-client ($server) {
	write-output "openssl s_client -status -connect $server:443"
	openssl s_client -status -connect $server:443
}

# Convert PEM private key, PEM certificate and PEM CA certificate (used by nginx, Apache, and other openssl apps)
# to a PKCS12 file (typically for use with Windows or Tomcat)
function convert-pem-to-p12 ($key, $cert, $cacert, $output) {
	write-output "openssl pkcs12 -export -inkey $key -in $cert -certfile $cacert -out $output"
	openssl pkcs12 -export -inkey $key -in $cert -certfile $cacert -out $output
}

# Convert a PKCS12 file to PEM
function convert-p12-to-pem ($p12file, $pem) {
	write-output "openssl pkcs12 -nodes -in $p12file -out $pemfile"
	openssl pkcs12 -nodes -in $p12file -out $pemfile
}

# Convert a crt to a pem file
function convert-crt-to-pem($crtfile) {
	write-output "openssl x509 -in $crtfile -out $basename.pem -outform PEM"
	openssl x509 -in $crtfile -out $basename.pem -outform PEM
}

# Check the modulus of an RSA certificate (to see if it matches a key)
function show-rsa-certificate-modulus {
	write-output "openssl x509 -noout -modulus -in "${1}" | shasum -a 256"
	openssl x509 -noout -modulus -in "${1}" | shasum -a 256
}

# Check the public point value of an ECDSA certificate (to see if it matches a key)
# See https://security.stackexchange.com/questions/73127/how-can-you-check-if-a-private-key-and-certificate-match-in-openssl-with-ecdsa
function show-ecdsa-certificate-ppv-and-curve {
	write-output "openssl x509 -in "${1}" -pubkey | shasum -a 256"
	openssl x509 -noout -pubkey -in "${1}" | shasum -a 256
}

# Check the modulus of an RSA key (to see if it matches a certificate)
function show-rsa-key-modulus {
	write-output "openssl rsa -noout -modulus -in "${1}" | shasum -a 256"
	openssl rsa -noout -modulus -in "${1}" | shasum -a 256
}

# Check the public point value of an ECDSA key (to see if it matches a certificate)
# See https://security.stackexchange.com/questions/73127/how-can-you-check-if-a-private-key-and-certificate-match-in-openssl-with-ecdsa
function show-ecc-key-ppv-and-curve {
	write-output "openssl ec -in "${1}" -pubout | shasum -a 256"openssl ec -in key -pubout
	openssl pkey -pubout -in "${1}" | shasum -a 256
}

# Check the modulus of a certificate request
function show-rsa-csr-modulus {
	write-output openssl req -noout -modulus -in "${1}" | shasum -a 256
	openssl req -noout -modulus -in "${1}" | shasum -a 256
}

# Encrypt a file (because zip crypto isn't secure)
function protect-file () {
	write-output openssl aes-256-cbc -in "${1}" -out "${2}"
	openssl aes-256-cbc -in "${1}" -out "${2}"
}

# Decrypt a file
function unprotect-file () {
	write-output aes-256-cbc -d -in "${1}" -out "${2}"
	openssl aes-256-cbc -d -in "${1}" -out "${2}"
}

# For setting up public key pinning
function convert-key-to-hpkp-pin() {
	write-output openssl rsa -in "${1}" -outform der -pubout | openssl dgst -sha256 -binary | openssl enc -base64
	openssl rsa -in "${1}" -outform der -pubout | openssl dgst -sha256 -binary | openssl enc -base64
}

# For setting up public key pinning (directly from the site)
function convert-website-to-hpkp-pin() {
	write-output openssl s_client -connect "${1}":443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
	openssl s_client -connect "${1}":443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
}
