#!/bin/sh
set -eu

BASE=/var/www/FreshRSS
# customize rclone config
RCLONE_CONF="$BASE/data/rclone.conf"
# change you target path
RCLONE_REMOTE="r2:backup/freshrss"

# just a debug
printenv | grep -i RCLONE || true

log() {
  echo "[$(date '+%F %T')] $*"
}

if [ ! -f "$RCLONE_CONF" ]; then
  log "ERROR: rclone config not found at $RCLONE_CONF"
  exit 1
fi

DATE=$(date +%F)
TMP=/tmp
ARCHIVE="$TMP/freshrss-$DATE.tar.gz"
LOCK="/tmp/freshrss-backup.lock"

# Prevent concurrent executions
if [ -e "$LOCK" ]; then
  log "Backup already running. Exiting."
  exit 0
fi
trap 'rm -f "$LOCK"' EXIT
touch "$LOCK"

cd "$BASE"

log "Backup started."

log "1. Running database backup (db-backup.php)."
./cli/db-backup.php

log "2. Creating archive: $ARCHIVE"
tar -czf "$ARCHIVE" \
  --exclude='data/users/*/db.sqlite' \
  .

LOCAL_SUM=$(sha256sum "$ARCHIVE" | awk '{print $1}')
log "3. Local checksum (sha256): $LOCAL_SUM"

log "4. Uploading archive to remote: $RCLONE_REMOTE"
rclone copy "$ARCHIVE" "$RCLONE_REMOTE" \
  --retries 2 \
  --low-level-retries 10

REMOTE_FILE="$(basename "$ARCHIVE")"
if rclone ls "$RCLONE_REMOTE" | grep -q "$REMOTE_FILE"; then
  log "5. Remote file presence verified: $REMOTE_FILE"
else
  log "5. ERROR: Remote file not found after upload."
  exit 1
fi

# 6. Cleanup local temporary archive
rm -f "$ARCHIVE"

log "Backup completed successfully."
