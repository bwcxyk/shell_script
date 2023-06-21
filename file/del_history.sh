#!/bin/bash
# set -ex

tmpdir="/data/tmpfile"

# find ${tmpdir} -type f -mtime +15 -print -exec rm -rf {} \;
# find ${tmpdir} -type d -ctime +15 | xargs rm -rf

find "${tmpdir}" -mindepth 2 -type d -mtime +15 -print0 | xargs -0 rm -rfv

echo "删除结束"
