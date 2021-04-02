#!/usr/bin/env bash
DATE=$(date '+%Y-%m-%d')
PP=$(pgrep -ofa host)
gdb -x gdb.commands /usr/lib/ckan/venv/bin/python3 $PP  > /var/lib/ckan/$DATE_gdb_ckan.txt
