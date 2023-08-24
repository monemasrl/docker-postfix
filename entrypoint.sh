#!/bin/bash

/usr/local/bin/dockerize -template /srv/templates/main.cf.tmpl:/etc/postfix/main.cf \
    -template /srv/templates/pgsql/relay_domains.cf.tmpl:/etc/postfix/pgsql/relay_domains.cf \
    -template /srv/templates/pgsql/virtual_mailbox_maps.cf.tmpl:/etc/postfix/pgsql/virtual_mailbox_maps.cf \
    -template /srv/templates/pgsql/virtual_alias_maps.cf.tmpl:/etc/postfix/pgsql/virtual_alias_maps.cf \
    -template /srv/templates/pgsql/virtual_domains_maps.cf.tmpl:/etc/postfix/pgsql/virtual_domains_maps.cf \

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord-postfix.conf -n
