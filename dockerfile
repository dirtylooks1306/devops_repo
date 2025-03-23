FROM alpine:3.19 AS builder

RUN apk add --no-cache php82 php82-fpm php82-mysqlnd php82-gd nginx supervisor

FROM alpine:3.19

# Install PHP-FPM and required extensions
RUN apk add --no-cache php82 php82-fpm php82-mysqlnd php82-gd nginx supervisor curl

RUN which php82-fpm || echo "php82-fpm not found"

WORKDIR /var/www/html

COPY src/ /var/www/html/
COPY default.conf /etc/nginx/http.d/default.conf

EXPOSE 80

# healthcheck
HEALTHCHECK CMD curl --fail http://localhost || exit 1

# Check if the nginx group and user already exist; if not, create them
RUN getent group nginx || addgroup -S nginx
RUN getent passwd nginx || adduser -S nginx -G nginx

USER nginx

# Start PHP-FPM and Nginx in the container
CMD ["/bin/sh", "-c", "php82-fpm -D && nginx -g 'daemon off;'"]
