#!/bin/bash

# Checks that at least one file in the directory has been modified in the last 24 hours.
# Pings URL (health check) with the result 

# Add to crontab e.g. every morning at 8am: 0 8 * * * /data/home/admin/scripts/modtimecheck.sh

# Set the directory to check
DIR=/data/Backup/sinixbackups/

HC_UUID=<uuid from healthchecks.io>

# Find a file that meets the criteria and quit as soon as it's found
RESULT=$(find "$DIR" -type f -daystart -mtime -1 -print -quit)

if [ -n "$RESULT" ]; then
    echo "Found at least one file modified in last 24 hours."
    curl --retry 3 "https://hc-ping.com/$HC_UUID"
else
    echo "Did not find any files modified in last 24 hours."
    curl --retry 3 "https://hc-ping.com/$HC_UUID/fail"
fi