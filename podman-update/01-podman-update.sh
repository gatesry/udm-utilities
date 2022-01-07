#!/bin/sh

mkdir -p /mnt/data/.cache

PODMAN_VERSION=v3.4.4
RUNC_VERSION=v1.0.3
CONMON_VERSION=v2.0.31
PODMAN_DL=/mnt/data/.cache/podman-$PODMAN_VERSION
RUNC_DL=/mnt/data/.cache/runc-$RUNC_VERSION
CONMON_DL=/mnt/data/.cache/conmon-$CONMON_VERSION
SECCOMP=/usr/share/containers/seccomp.json

while [ ! -f $CONMON_DL ]; do
  curl -fsSLo $CONMON_DL https://github.com/gatesry/udm-utilities/blob/master/podman-update/build/conmon-v2.0.30?raw=true
  sleep 1
done
chmod +x $CONMON_DL
if [ ! -f /usr/libexec/podman/conmon.old ]; then
  mv /usr/libexec/podman/conmon /usr/libexec/podman/conmon.old
fi
ln -s $CONMON_DL /usr/libexec/podman/conmon

if [ ! -f $PODMAN_DL ]; then
  curl -fsSLo $PODMAN_DL https://github.com/gatesry/udm-utilities/blob/master/podman-update/build/podman-v3.4.2?raw=true
fi
chmod +x $PODMAN_DL
if [ ! -f /usr/bin/podman.old ]; then
  mv /usr/bin/podman /usr/bin/podman.old
fi
ln -s $PODMAN_DL /usr/bin/podman

if [ ! -f $RUNC_DL ]; then
  curl -fsSLo $RUNC_DL https://github.com/gatesry/udm-utilities/blob/master/podman-update/build/runc-v1.0.2?raw=true
fi
chmod +x $RUNC_DL
if [ ! -f /usr/bin/runc.old ]; then
  mv /usr/bin/runc /usr/bin/runc.old
fi
ln -s $RUNC_DL /usr/bin/runc

if [ ! -f $SECCOMP ]; then
  mkdir -p /usr/share/containers/
  curl -fsSLo $SECCOMP https://github.com/gatesry/udm-utilities/blob/master/podman-update/build/seccomp.json?raw=true
fi
sed -i 's/driver = ""/driver = "overlay"/' /etc/containers/storage.conf
sed -i 's/ostree_repo = ""/#ostree_repo = ""/' /etc/containers/storage.conf
# Comment out if you don't want to enable docker-compose or remote docker admin
/usr/bin/podman system service --time=0 tcp:0.0.0.0:2375 &

