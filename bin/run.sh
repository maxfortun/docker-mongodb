#!/bin/bash -ex

pushd "$(dirname $0)"
SWD=$(pwd)
BWD=$(dirname "$SWD")

. $SWD/setenv.sh

RUN_IMAGE="$REPO/$NAME"

DOCKER_RUN_ARGS=( -e container=docker )
DOCKER_RUN_ARGS+=( -v /etc/resolv.conf:/etc/resolv.conf:ro )
DOCKER_RUN_ARGS+=( --add-host host.docker:$(ipconfig getifaddr en0) )

# Publish exposed ports
imageId=$(docker images --format="{{.Repository}} {{.ID}}"|grep "^$RUN_IMAGE "|awk '{ print $2 }')
while read port; do
	proto=${port##*/}
	portOnly=${port%/*}
	pad=$(( 5 - ${#portOnly} ))
	hostPort=${DOCKER_PORT_PREFIX:0:$pad}${port%%/*}
	[ ${#hostPort} -gt 5 ] && hostPort=${hostPort:${#hostPort}-5}
	DOCKER_RUN_ARGS+=( -p $hostPort:$port )
done < <(docker image inspect -f '{{json .Config.ExposedPorts}}' $imageId|jq -r 'keys[]')


HOST_MNT=${HOST_MNT:-$BWD/mnt}
GUEST_MNT=${GUEST_MNT:-$BWD/mnt}

DOCKER_RUN_ARGS+=( -v $GUEST_MNT/etc/mongo:/etc/mongo )
DOCKER_RUN_ARGS+=( -v $GUEST_MNT/var/lib/mongodb:/var/lib/mongodb )
DOCKER_RUN_ARGS+=( -e MONGO_INITDB_ROOT_USERNAME_FILE=/etc/mongo/admin-username )
DOCKER_RUN_ARGS+=( -e MONGO_INITDB_ROOT_PASSWORD_FILE=/etc/mongo/admin-password )

docker update --restart=no $NAME || true
docker stop $NAME || true
docker system prune -f
docker run -d -it --restart=always "${DOCKER_RUN_ARGS[@]}" --name $NAME $RUN_IMAGE:$VERSION "$@"

echo "To attach to container run 'docker attach $NAME'. To detach CTRL-P CTRL-Q."
[ "$DOCKER_ATTACH" != "true" ] || docker attach $NAME


