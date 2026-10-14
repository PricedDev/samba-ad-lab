#!/usr/bin/env bash
# Zeigt die Verbindungsdaten fuer die anderen Services/Teams.
cd "$(dirname "$0")"
v() { grep "^$1=" .env | cut -d= -f2-; }
B="DC=${REALM_LC:-$(v REALM_LC)}"; B="DC=$(v REALM_LC | sed 's/\./,DC=/g')"
IP=$(v BIND_IP)
cat <<INFO

=== Samba AD DC bereit ===
Host / DNS-Server : $IP   (im Docker-Netz lab-net: samba-dc)
LDAP              : ldap://$IP:389      LDAPS: ldaps://$IP:636 (self-signed)
Base-DN           : $B
Bind-DN (Service) : CN=svc-ldap,OU=Dienstkonten,$B
                    oder svc-ldap@$(v REALM_LC)
Bind-Passwort     : $(v SVC_LDAP_PASS)
Admin             : Administrator@$(v REALM_LC) / $(v ADMIN_PASS)
Testuser          : anna.beispiel, max.muster, lisa.test  (Passwort: $(v SEED_USER_PASS))
Gruppen           : IT, Vertrieb, Personal, Projektleitung   (OU=Abteilungen)
SMB               : \\\\$IP\\sysvol  (Port $(v SMB_PORT))
INFO
