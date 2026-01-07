#!/bin/sh
set -e

DATE=$(date +%F)
BASE=/var/www/FreshRSS
TMP=/tmp
ARCHIVE=$TMP/freshrss-$DATE.tar.gz

cd $BASE

echo 'Back up starting.'
tar -czf $ARCHIVE data

# remote from env
rclone copy "$ARCHIVE" "${RCLONE_REMOTE}"

rm -f "$ARCHIVE"
echo 'Back up complete.'
