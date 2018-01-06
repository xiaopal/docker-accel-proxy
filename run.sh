#! /bin/bash

bool_flag(){
	[[ "${1,,}" =~ ^(y|yes|true|on|1)$ ]]
}

init(){
	local OPTIONS_PORT="http_port ${PROXY_PORT:-8888}" OPTIONS_EXTRA
	bool_flag "${PROXY_ACCESS_LOG:-N}" \
		&& OPTIONS_EXTRA="$OPTIONS_EXTRA"$'\n'"access_log stdio:/dev/stdout" \
		|| OPTIONS_EXTRA="$OPTIONS_EXTRA"$'\n'"access_log none"

	bool_flag "${PROXY_SSL_BUMP:-Y}" && {
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
		OPTIONS_PORT="$OPTIONS_PORT ssl-bump generate-host-certificates=on cert=$CA_CRT key=$CA_KEY"
		OPTIONS_EXTRA="$OPTIONS_EXTRA"$'\n'"ssl_bump bump all"
		OPTIONS_EXTRA="$OPTIONS_EXTRA"$'\n'"sslcrtd_children 1"
		bool_flag "${PROXY_CERT_ERROR:-N}" && {
			OPTIONS_EXTRA="$OPTIONS_EXTRA"$'\n'"sslproxy_cert_error allow all"
			OPTIONS_EXTRA="$OPTIONS_EXTRA"$'\n'"sslproxy_cert_adapt setCommonName all"
		}
	}
	cat<<EOF >/etc/squid/squid.conf
$OPTIONS_PORT
$OPTIONS_EXTRA

shutdown_lifetime 0
cache_log /dev/stderr
http_access allow all
always_direct allow all
cache deny all	
EOF
}

init &&	chown squid:squid /dev/stdout \
	&& chown squid:squid /dev/stderr \
	&& exec /usr/sbin/squid -N -f /etc/squid/squid.conf
