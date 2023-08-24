#!/bin/bash

/usr/local/bin/dockerize -template /srv/templates/postfix/main.cf.tmpl:/etc/postfix/main.cf \
    -template /srv/templates/postfix/pgsql/relay_domains.cf.tmpl:/etc/postfix/pgsql/relay_domains.cf \
    -template /srv/templates/postfix/pgsql/virtual_mailbox_maps.cf.tmpl:/etc/postfix/pgsql/virtual_mailbox_maps.cf \
    -template /srv/templates/postfix/pgsql/virtual_alias_maps.cf.tmpl:/etc/postfix/pgsql/virtual_alias_maps.cf \
    -template /srv/templates/postfix/pgsql/virtual_domains_maps.cf.tmpl:/etc/postfix/pgsql/virtual_domains_maps.cf \
    -template /srv/templates/sasl2/smtpd.conf.tmpl:/etc/sasl2/smtpd.conf 

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord-postfix.conf -n
