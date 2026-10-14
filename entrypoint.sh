#!/bin/bash
set -euo pipefail
if [ ! -f /var/lib/samba/private/sam.ldb ]; then
  echo ">> Provisioning ${REALM} (${DOMAIN})"
  rm -f /etc/samba/smb.conf
  samba-tool domain provision --use-rfc2307 --server-role=dc \
    --realm="${REALM}" --domain="${DOMAIN}" --adminpass="${ADMIN_PASS}" \
    --dns-backend=SAMBA_INTERNAL --option="dns forwarder=${DNS_FORWARDER}"
fi
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
# Lab-Komfort: Simple Bind auch ueber 389 erlauben (Tools wie n8n/IceHrm/Zamad)
if ! grep -q 'ldap server require strong auth' /etc/samba/smb.conf; then
  sed -i '/^\[global\]/a\\tldap server require strong auth = no' /etc/samba/smb.conf
fi
samba -i --debug-stdout &
PID=$!
trap 'kill -TERM $PID 2>/dev/null' TERM INT
/seed.sh &
wait $PID
