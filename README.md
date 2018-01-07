#accel-proxy

```
docker run -d -p 8888:8888 \
    -e PROXY_SSL_BUMP=Y \
    -e PROXY_CERT_ERROR=N \
    -e PROXY_ACCESS_LOG=N \
    -v /etc/accel-proxy:/etc/accel-proxy \
    xiaopal/accel-proxy:latest

http_proxy=127.0.0.1:8888 https_proxy=127.0.0.1:8888 \
curl -v 'https://www.baidu.com/'

```