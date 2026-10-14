#!/usr/bin/env bash
# One-Command-Setup: .env erzeugen (Zufalls-Passwoerter, LAN-IP), bauen, starten, warten, Info.
set -euo pipefail
cd "$(dirname "$0")"
command -v docker >/dev/null || { echo "Docker fehlt"; exit 1; }
gen() { echo "Lab-$(head -c 12 /dev/urandom | base64 | tr -dc 'A-Za-z0-9')9!"; }
[ -f .env ] || { touch .env; chmod 600 .env; }
while IFS= read -r line; do               # fehlende Keys aus .env.example ergaenzen
  k=${line%%=*}; case "$line" in \#*|"") continue;; esac
  grep -q "^$k=" .env && continue
  case "$k" in ADMIN_PASS|SVC_LDAP_PASS) line="$k=$(gen)";; esac
  echo "$line" >> .env
done < .env.example
for k in ADMIN_PASS SVC_LDAP_PASS; do
  grep -q "^$k=CHANGE_ME" .env && sed -i "s|^$k=.*|$k=$(gen)|" .env
done
ip=${BIND_IP_OVERRIDE:-}
[ -z "$ip" ] && ip=$(ip -4 route get 1.1.1.1 2>/dev/null | sed -n 's/.* src \([0-9.]*\).*/\1/p' || true)
[ -z "$ip" ] && ip=$(ipconfig getifaddr en0 2>/dev/null || true)
[ -z "$ip" ] && ip=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
[ -n "$ip" ] && sed -i "s|^BIND_IP=.*|BIND_IP=$ip|" .env
echo ">> Starte DC auf $(grep ^BIND_IP= .env | cut -d= -f2) (Erststart ~2 Min.)"
docker compose up -d --build --wait --wait-timeout 420
./info.sh
