#!/bin/bash -ex

pushd "$(dirname $0)"
SWD=$(pwd)
BWD=$(dirname "$SWD")

. $SWD/setenv.sh

ip=$(ipconfig getifaddr en0) 
port=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{$p}} -> {{(index $conf 0).HostPort}} {{end}}' mongodb|sed -e 's/^[ ]*//g' -e 's/[^0-9].*$//g')

HOST_MNT=${HOST_MNT:-$BWD/mnt}
GUEST_MNT=${GUEST_MNT:-$BWD/mnt}

[ -n "$1" ] && db=$1 && shift

username=$(cat $GUEST_MNT/etc/mongo/admin-username)
password=$(cat $GUEST_MNT/etc/mongo/admin-password)
docker run -it --rm mongo mongo "mongodb://$ip:$port/$db" -u "$username" -p "$password" "$@"

