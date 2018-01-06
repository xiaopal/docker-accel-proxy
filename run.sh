#! /bin/bash

init(){
	local CA_CRT='/etc/accel-proxy/ca.crt' \
		CA_KEY='/etc/accel-proxy/ca.key' \
		CA_SUBJECT="/C=CN/OU=ROOT" \
		CA_DAYS=3650

	[ -f "$CA_KEY" ] || {
		openssl genrsa -out "$CA_KEY" 2048 || return 1
		rm -f "$CA_CRT"
	}
	[ -f "$CA_CRT" ] || openssl req -days "$CERT_DAYS" -new -x509 -key "$CA_KEY" -out "$CA_CRT" \
			-subj "$CA_SUBJECT" || return 1
}

init &&	chown squid:squid /dev/stdout \
	&& chown squid:squid /dev/stderr \
	&& exec /usr/sbin/squid -N -f /etc/squid/squid.conf
