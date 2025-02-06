FROM lscr.io/linuxserver/dokuwiki:latest
RUN apk add --no-cache php8-curl php8-json
COPY approvals /var/www/html/approvals
COPY approvals_ui /var/www/html/approvals_ui
RUN chown -R abc:abc /var/www/html/approvals /var/www/html/approvals_ui
