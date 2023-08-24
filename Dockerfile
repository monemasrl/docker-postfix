# syntax=docker/dockerfile:1.4
ARG VERSION=latest
FROM alpine:$VERSION
ENV DOCKERIZE_VERSION v0.7.0

LABEL maintainer="Andrea Bettarini <bettarini@monema.it>"
LABEL org.opencontainers.image.authors="Andrea Bettarini <bettarini@monema.it>"
LABEL org.opencontainers.image.description="Postfix with SASL authentication, Postgres, TLS and DKIM support"
LABEL org.opencontainers.image.documentation="https://github.com/monemasrl/docker-postfix"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/monemasrl/docker-postfix"
LABEL org.opencontainers.image.title="monemaweb/postfix"
LABEL org.opencontainers.image.url="https://github.com/monemasrl/docker-postfix"

# install dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-arm64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-arm64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-arm64-$DOCKERIZE_VERSION.tar.gz

RUN apk update
RUN apk --no-cache --upgrade add \
    bash \
    gomplate \
    ca-certificates \
    pam-pgsql \
    cyrus-sasl \
    cyrus-sasl-pam \
    cyrus-sasl-crammd5 \
    cyrus-sasl-digestmd5 \
    cyrus-sasl-login \
    cyrus-sasl-ntlm \
    cyrus-sasl-sql \
    postfix \
    postfix-pgsql \
    supervisor
    # && rm -Rf /usr/share/doc && rm -Rf /usr/share/man

# Set up configuration
ENV OPENDKIM_HOST= \
    OPENDKIM_PORT= \
    POSTFIX_maillog_file=/dev/stdout \
    POSTFIX_smtpd_tls_cert_file= \
    POSTFIX_smtpd_tls_key_file= \
    POSTFIX_smtpd_tls_security_level=may \
    POSTFIX_smtpd_tls_ciphers=high \
    POSTFIX_smtpd_tls_exclude_ciphers=aNULL,MD5 \
    POSTFIX_smtpd_tls_protocols=>=TLSv1.2 \
    SMTP_USER= \
    SMTP_PASSWORD=

# Set up volumes
VOLUME     [ "/var/spool/postfix" ]

# Set Postfix run environment
USER       root
WORKDIR    /etc/postfix

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD printf "EHLO healthcheck\n" | nc 127.0.0.1 587 | grep -qE "^220.*ESMTP Postfix"

EXPOSE     587
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
COPY ./templates /srv/templates
COPY ./configs/supervisord/supervisord-postfix.conf /etc/supervisor/conf.d/supervisord-postfix.conf
RUN mkdir /etc/postfix/pgsql

RUN mkdir -p /var/run/saslauthd
RUN mkdir -p /var/spool/postfix/var/run/saslauthd
# RUN chown root:sasl /var/run/saslauthd
RUN chmod 710 /var/run/saslauthd
# RUN chmod --reference=/var/run/saslauthd /var/spool/postfix/var/run/saslauthd

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
