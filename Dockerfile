# syntax=docker/dockerfile:1.4
FROM ubuntu:22.04

ENV DOCKERIZE_VERSION v0.7.0

LABEL maintainer="Andrea Bettarini <bettarini@monema.it>"
LABEL org.opencontainers.image.authors="Andrea Bettarini <bettarini@monema.it>"
LABEL org.opencontainers.image.description="Postfix with SASL authentication, Postgres, TLS and DKIM support"
LABEL org.opencontainers.image.documentation="https://github.com/monemasrl/docker-postfix"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/monemasrl/docker-postfix"
LABEL org.opencontainers.image.title="monemaweb/postfix"
LABEL org.opencontainers.image.url="https://github.com/monemasrl/docker-postfix"

RUN apt-get update
RUN apt-get -y install \
    bash \
    wget \
    netcat \
    iputils-ping \
    ca-certificates \
    sasl2-bin \
    swaks \
    rsyslog \
    vim dnsutils less \
    libsasl2-modules \
    libpam-pgsql \
    supervisor
    # libsasl2-modules-sql \
    # && rm -rf /var/lib/apt/lists/*
    # && rm -Rf /usr/share/doc && rm -Rf /usr/share/man

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y postfix postfix-pgsql
# install dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-arm64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-arm64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-arm64-$DOCKERIZE_VERSION.tar.gz


# Set up volumes
VOLUME     [ "/var/spool/postfix" ]

# Set Postfix run environment
USER       root
WORKDIR    /etc/postfix

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD printf "EHLO healthcheck\n" | nc 127.0.0.1 587 | grep -qE "^220.*ESMTP Postfix"

EXPOSE     587
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN mkdir /etc/postfix/pgsql
RUN mkdir /etc/sasl2
RUN mkdir -p /var/run/saslauthd
RUN mkdir -p /var/spool/postfix/var/run/saslauthd
COPY ./configs/rsyslog/rsyslog.conf /etc/rsyslog.conf
COPY ./templates /srv/templates
COPY ./scripts /srv/scripts
COPY ./configs/pam/smtp /etc/pam.d/smtp
COPY ./configs/pam/smtpd /etc/pam.d/smtpd
COPY ./configs/sasl2/smtpd.conf /etc/sasl2/smtpd.conf
COPY ./configs/postfix/sasl/smtpd.conf /etc/postfix/sasl/smtpd.conf
COPY ./configs/supervisord/supervisord-postfix.conf /etc/supervisor/conf.d/supervisord-postfix.conf
# RUN chown root:sasl /var/run/saslauthd
RUN chmod 710 /var/run/saslauthd

RUN usermod -a -G sasl postfix
# RUN chmod --reference=/var/run/saslauthd /var/spool/postfix/var/run/saslauthd

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

