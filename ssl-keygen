# !/bin/bash
# This script creates an OpenSSL private key, certificate signing request, and self-signed certificate.
# You must supply a at least a Common Name argument (e.g., example.com) or else include it in your config file.

printHelp () {
	echo "Usage: $0 CN [-c CONFPATH]"
	echo "       CN: common name to identify the host (e.g., example.com)"
	echo "       -c CONFPATH: path of file containing certificate configuration"
	echo "                 (e.g., example.com.ssl.conf)"
	exit 1
}

if [[ $# -eq 0 ]]; then
	printHelp
fi
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-h|--help)
		printHelp
		;;
		-c|--config)
		CONFIG=$2
		shift
		;;
		*)
		CN=$1
	esac
	shift
done

if [ "$CONFIG" ]; then
	# Generate new key & CSR, 2048-bit RSA, don't encrypt key, sign with SHA-256
	openssl req -newkey rsa:2048 -nodes -sha256 -keyout $CN.key -out $CN.csr -config $CONFIG
else
	# Generate new key & CSR, 2048-bit RSA, don't encrypt key, sign with SHA-256. Use default configuration. DON'T USE THIS FOR SAN CERTS!
	openssl req -newkey rsa:2048 -nodes -sha256 -keyout $CN.key -out $CN.csr -subj /CN=$CN
fi
echo "Verifying private key..."
openssl rsa -in $CN.key -check
echo "Verifying certificate signing request..."
openssl req -text -noout -verify -in $CN.csr
#openssl genrsa -out $CN.key 2048
openssl x509 -req -days 365 -in $CN.csr -signkey $CN.key -out $CN.crt
# Lock down private key
chmod 600 $CN.key
echo "Verifying self-signed certificate..."
openssl x509 -in $CN.crt -text -noout

echo ""
echo "Private key: $CN.key"
echo "Certificate request: $CN.csr"
echo "Self-signed certificate: $CN.crt"
