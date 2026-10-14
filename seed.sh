#!/bin/bash
# Einmaliges Seeding (OUs, Gruppen, Testuser, Service-User). Marker verhindert Wiederholung.
set -uo pipefail
M=/var/lib/samba/.seeded
[ -f "$M" ] && exit 0
for _ in $(seq 1 90); do samba-tool domain level show >/dev/null 2>&1 && break; sleep 2; done
BASE="DC=${REALM_LC//./,DC=}"
UP="${SEED_USER_PASS:-Passw0rd!2026}"
echo ">> Seeding ${BASE}"
samba-tool ou create "OU=Abteilungen,$BASE" || true
samba-tool ou create "OU=Dienstkonten,$BASE" || true
for g in IT Vertrieb Personal Projektleitung; do samba-tool group add "$g" || true; done
mk() { samba-tool user create "$1" "$2" --given-name="$3" --surname="$4" --userou="$5" || true; }
mk anna.beispiel "$UP" Anna Beispiel "OU=Abteilungen"
mk max.muster    "$UP" Max  Muster   "OU=Abteilungen"
mk lisa.test     "$UP" Lisa Test     "OU=Abteilungen"
samba-tool group addmembers IT anna.beispiel || true
samba-tool group addmembers Vertrieb max.muster || true
samba-tool group addmembers Personal lisa.test || true
samba-tool group addmembers Projektleitung anna.beispiel || true
mk svc-ldap "${SVC_LDAP_PASS}" Service LDAP "OU=Dienstkonten"
samba-tool user setexpiry svc-ldap --noexpiry || true
touch "$M"
echo ">> Seeding fertig"
