#!/bin/bash
set -eu

if [ $# -ne 3 ]; then
  echo "./restore.sh <name of data container> <directory path of backup file> <backup filename>"
  exit 1
fi

docker run --rm --volumes-from $1 \
-v $2:/backup \
-e TAR_OPTS="--verbose" boombatower/docker-backup restore $3
