#!/bin/bash

# echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

touch "/home/oys/bash-scripts/inoti.csv"
rm "/home/oys/bash-scripts/inoti.csv"
touch "/home/oys/bash-scripts/inoti.csv"
chmod ugo+rwx "/home/oys/bash-scripts/inoti.csv"

EXCLUDES_READ=""
EXCLUDES=""

readarray -t EXCLUDES_READ </home/oys/bash-scripts/inoti-excludes.txt

for i in "${!EXCLUDES_READ[@]}"; do
    if [ -z "${EXCLUDES}" ]; then
        EXCLUDES="${EXCLUDES_READ[i]}"
    else
        EXCLUDES+="|${EXCLUDES_READ[i]}"
    fi
done

printf "\nExcludes = ${EXCLUDES}\n"

sudo inotifywait / -rmq -e create,modify,move,delete,delete_self,unmount \
    --format "%T,%:e,%w%f" --timefmt "%y%m%d-%H:%M:%S" -o "/home/oys/bash-scripts/inoti.csv" --excludei "${EXCLUDES}"

