#!/bin/bash
set -eu

if [ $# -ne 2 ]; then
  echo "./backup.sh <name of data container> <directory path of backup file>"
  exit 1
fi

docker run --rm --volumes-from $1 \
-v $2:/backup \
-e TAR_OPTS="--verbose" boombatower/docker-backup backup $1_$(date +%F_%H%M).tar.xz
