FROM debian:12-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      samba samba-ad-provision samba-dsdb-modules samba-vfs-modules winbind krb5-user smbclient \
      ldb-tools ldap-utils dnsutils acl attr procps \
 && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh seed.sh /
RUN chmod +x /entrypoint.sh /seed.sh
EXPOSE 53/tcp 53/udp 88/tcp 88/udp 135/tcp 139/tcp 389/tcp 389/udp 445/tcp 464/tcp 464/udp 636/tcp 3268/tcp 3269/tcp
ENTRYPOINT ["/entrypoint.sh"]
