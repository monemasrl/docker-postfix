#! /bin/bash
set -e

# Configure Postfix:
# POSTFIX_var env -> postconf -e var=$POSTFIX_var
postfix_config() {
    for var in ${!POSTFIX_*}; do
        postconf -e "${var:8}=${!var}"
    done
}

# Configure SASL authentication
sasl_config() {
    echo "Configuring SASL authentication"
    postconf -e 'smtpd_sasl_local_domain ='
    postconf -e 'smtpd_sasl_auth_enable = yes'
    postconf -e 'broken_sasl_auth_clients = yes'
    #postconf -e 'smtpd_sasl_security_options = noanonymous,noplaintext'
    #postconf -e 'smtpd_sasl_tls_security_options = noanonymous'
    postconf -e 'smtpd_relay_restrictions = permit_sasl_authenticated,reject_unauth_destination'
    postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'
}

tls_config() {
    echo "Configuring TLS"
    postconf -e smtp_tls_security_level=may
    postconf -e smtpd_tls_security_level=may
    postconf -e smtpd_tls_auth_only=yes
    postconf -e smtp_tls_note_starttls_offer=yes
    postconf -e smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
    postconf -e smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
    postconf -e smtpd_tls_loglevel=1
    postconf -e smtpd_tls_received_header=yes
    postconf -e smtpd_tls_session_cache_timeout=3600s
    postconf -e tls_random_source=dev:/dev/urandom

    postconf -P "submission/inet/smtpd_tls_security_level=encrypt"
    postconf -P "submission/inet/milter_macro_daemon_name=ORIGINATING"
}

configure_dkim() {
    if [[ -n "${OPENDKIM_HOST}" ]] && [[ "${OPENDKIM_PORT}" ]]; then
        echo "Configuring DKIM"
        postconf -e milter_default_action=accept
        postconf -e milter_protocol=2
        postconf -e smtpd_milters="inet:${OPENDKIM_HOST}:${OPENDKIM_PORT}"
        postconf -e non_smtpd_milters="inet:${OPENDKIM_HOST}:${OPENDKIM_PORT}"
    fi
}

# Enable port 587
configure_submission() {
    echo "Configuring submission"
    postconf -M submission/inet="submission   inet   n   -   n   -   -   smtpd"
}

