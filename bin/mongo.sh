#!/bin/bash -ex

ip=$(ipconfig getifaddr en0) 
port=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{$p}} -> {{(index $conf 0).HostPort}} {{end}}' mongodb|sed -e 's/^[ ]*//g' -e 's/[^0-9].*$//g')

docker run -it --rm mongo mongo $ip:$port "$@"
