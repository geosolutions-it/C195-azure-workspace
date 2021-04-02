#!/usr/bin/env bash
DATE=$(date '+%Y-%m-%d')

gdb -x gdb.commands /usr/lib/ckan/venv/bin/python3 38  > /var/lib/ckan/$DATE_gdb_ckan.txt
