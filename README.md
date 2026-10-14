# Samba AD DC im Docker-Container

Benutzerverwaltung mit Verzeichnisdienst (Samba 4 Active Directory) für das
Projekt „Projektgruppen On-/Offboarding". Realm `LAB.LOCAL`, Domain `LAB`.

## Start (ein Befehl)
    git clone https://github.com/PricedDev/samba-ad-lab && cd samba-ad-lab
    ./setup.sh

`setup.sh` erzeugt `.env` (Zufalls-Passwörter, erkennt die LAN-IP), baut, startet,
wartet bis alles fertig ist und zeigt die Verbindungsdaten. Später jederzeit: `./info.sh`.
Eigene IP erzwingen: `BIND_IP_OVERRIDE=192.168.x.y ./setup.sh`

## Was automatisch da ist (Seed beim ersten Start)
| Was | Wert |
|---|---|
| Base-DN | `DC=lab,DC=local` |
| OUs | `Abteilungen`, `Dienstkonten` |
| Gruppen | IT, Vertrieb, Personal, Projektleitung |
| Testuser | anna.beispiel (IT, Projektleitung), max.muster (Vertrieb), lisa.test (Personal) |
| Service-User für Bind | `svc-ldap@lab.local` (läuft nie ab), Passwort in `.env` |

## Anbindung anderer Services (n8n, IceHrm, Zamad, OPSI …)
- **LDAP:** `ldap://<BIND_IP>:389` – Simple Bind erlaubt (Lab-Einstellung); LDAPS `ldaps://<BIND_IP>:636` (self-signed)
- **Im selben Docker-Host:** `docker network` `lab-net`, Host `samba-dc`. In deren Compose-File:
  ```yaml
  networks: { lab-net: { external: true } }
  ```
  und beim Service `networks: [lab-net]`. Dann reicht `ldap://samba-dc:389`.
- **Bind-DN:** `svc-ldap@lab.local` · **Base-DN:** `DC=lab,DC=local` · **User-Filter:** `(sAMAccountName=%s)`
- **DNS:** nur für Domain-Join nötig, dann `<BIND_IP>` als DNS-Server eintragen.

## Firewall / Ports
Ports: 53, 88, 135, 139, 389, 445, 464, 636, 3268, 3269 (TCP/UDP wo nötig). Beispiel ufw:

    sudo ufw allow from 10.31.0.0/16 to any port 53,88,135,139,389,445,464,636,3268,3269

Ist 445/139 belegt (Windows-Host, OPSI): in `.env` `SMB_PORT=1445` / `NETBIOS_PORT=1139` setzen.

## Verwaltung
    docker exec samba-dc samba-tool user create max2 'Passw0rd!2026' --userou=OU=Abteilungen
    docker exec samba-dc samba-tool group addmembers IT max2
    docker exec samba-dc samba-tool user list
    docker exec samba-dc samba-tool group listmembers IT

## Hinweise
- Daten in Volumes `samba-data`/`samba-etc`. **Zurücksetzen:** `docker compose down -v && ./setup.sh`
- Container braucht `cap_add: SYS_ADMIN` (NT-ACL-Xattrs).
- Port 53 wird auf `BIND_IP` gebunden (nicht 0.0.0.0, wegen systemd-resolved).
- Lab-Setup: kein produktiver Einsatz (Simple Bind auf 389, self-signed Zertifikat).
