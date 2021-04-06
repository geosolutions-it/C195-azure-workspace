#!/usr/bin/env bash
DATE=$(date '+%Y-%m-%d-%H%M')
PP=$(pgrep -ofa host | awk '{print $1}')
gdb -x gdb.commands /usr/lib/ckan/venv/bin/python3 $PP  > /var/lib/ckan/${DATE}_gdb_ckan.txt
