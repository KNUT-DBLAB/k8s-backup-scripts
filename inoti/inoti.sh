#!/bin/bash

EXCLUDES_READ=""
EXCLUDES=""

readarray -t EXCLUDES_READ </home/oys/grad-exp/inoti/inoti-excludes.txt

for i in "${!EXCLUDES_READ[@]}"; do
    if [ -z "${EXCLUDES}" ]; then
        EXCLUDES="${EXCLUDES_READ[i]}"
    else
        EXCLUDES+="|${EXCLUDES_READ[i]}"
    fi
done

printf "\nExcludes = ${EXCLUDES}\n"

sudo inotifywait / -rmq -e create,modify,move,delete,delete_self,unmount \
    --format "%T,%:e,%w%f" --timefmt "%y%m%d-%H:%M:%S" -o "/home/oys/grad-exp/inoti/inoti.csv" --excludei "${EXCLUDES}"
