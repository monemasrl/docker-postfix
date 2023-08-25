#!/bin/bash

source /srv/scripts/lib/postfix.sh

mkdir -p  /var/spool/postfix/etc/
cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf

/usr/local/bin/dockerize -template /srv/templates/postfix/main.cf.tmpl:/etc/postfix/main.cf \
    -template /srv/templates/postfix/pgsql/relay_domains.cf.tmpl:/etc/postfix/pgsql/relay_domains.cf \
    -template /srv/templates/postfix/pgsql/virtual_mailbox_maps.cf.tmpl:/etc/postfix/pgsql/virtual_mailbox_maps.cf \
    -template /srv/templates/postfix/pgsql/virtual_alias_maps.cf.tmpl:/etc/postfix/pgsql/virtual_alias_maps.cf \
    -template /srv/templates/postfix/pgsql/virtual_domains_maps.cf.tmpl:/etc/postfix/pgsql/virtual_domains_maps.cf \
    -template /srv/templates/pam_pgsql.conf.tmpl:/etc/pam_pgsql.conf 
    # -template /srv/templates/sasl2/smtpd.conf.tmpl:/etc/sasl2/smtpd.conf \
    # -template /srv/templates/security/pam_pgsql.conf.tmpl:/etc/security/pam_pgsql.conf \

postfix_config
sasl_config
tls_config
configure_dkim
configure_submission

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord-postfix.conf -n
