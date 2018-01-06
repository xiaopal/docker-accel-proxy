FROM alpine:3.7

RUN apk add --no-cache squid curl bash openssl \
	&& /usr/lib/squid/ssl_crtd -c -s /var/lib/ssl_db \
	&& chown -R squid:squid /var/lib/ssl_db
ADD run.sh /run.sh
RUN mkdir -p /etc/accel-proxy && chmod a+x /run.sh
CMD ["/run.sh"]
EXPOSE 8888
