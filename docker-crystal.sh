#!/usr/bin/env bash

set -o errexit
set -o nounset

# Get the version of Crystal to be using
if [ -f shard.yml ]; then
  # Naively extract from shard.yml
  CRYSTAL_VERSION=`grep 'crystal:' shard.yml | awk '{print $2}'`
else
  (>&2 echo "Could not find shard.yml")
  CRYSTAL_VERSION="latest"
fi
(>&2 echo "⬡ Using crystal:${CRYSTAL_VERSION}")

# Build any additional args needed for sub-commands
declare -a DOCKER_ARGS=("")
declare -a CRYSTAL_ARGS=("")
case "$1" in
  play)
    PORT=`echo "$*" | grep -oP "(-p)|(\--port)\s+\K\d+" || echo 8080`
    DOCKER_ARGS+="--publish ${PORT}:${PORT}"
    CRYSTAL_ARGS+="--binding 0.0.0.0"
    ;;
esac

docker run \
    --rm \
    --tty \
    --volume `pwd`:/data \
    --workdir /data \
    ${DOCKER_ARGS} \
    crystallang/crystal:${CRYSTAL_VERSION} \
    crystal $* ${CRYSTAL_ARGS}
