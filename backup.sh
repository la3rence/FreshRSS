#!/bin/sh
set -eu

DATE=$(date +%F)
BASE=/var/www/FreshRSS
TMP=/tmp
ARCHIVE="$TMP/freshrss-$DATE.tar.gz"
LOCK="/tmp/freshrss-backup.lock"

log() {
  echo "[$(date '+%F %T')] $*"
}

# Prevent concurrent executions (cron overlap protection)
if [ -e "$LOCK" ]; then
  log "Backup already running. Exiting."
  exit 0
fi
trap 'rm -f "$LOCK"' EXIT
touch "$LOCK"

cd "$BASE"

log "Backup started."

# Create a consistent database backup using FreshRSS CLI
# https://freshrss.github.io/FreshRSS/en/admins/05_Backup.html
log "Running database backup (db-backup.php)."
./cli/db-backup.php

# Create archive while excluding the live SQLite database
log "Creating archive: $ARCHIVE"
tar -czf "$ARCHIVE" \
  --exclude='data/users/*/db.sqlite' \
  .

# Calculate local checksum
LOCAL_SUM=$(sha256sum "$ARCHIVE" | awk '{print $1}')
log "Local checksum (sha256): $LOCAL_SUM"

# Upload archive to remote storage
log "Uploading archive to remote: $RCLONE_REMOTE"
rclone copy "$ARCHIVE" "$RCLONE_REMOTE" \
  --checksum \
  --retries 3 \
  --low-level-retries 10

# Verify remote checksum
REMOTE_FILE="$(basename "$ARCHIVE")"
REMOTE_SUM=$(rclone hashsum sha256 "$RCLONE_REMOTE" | grep "$REMOTE_FILE" | awk '{print $1}')

if [ "$LOCAL_SUM" = "$REMOTE_SUM" ]; then
  log "Checksum verification passed."
  log "Remote checksum (sha256): $REMOTE_SUM"
else
  log "ERROR: Checksum verification failed."
  log "Local checksum : $LOCAL_SUM"
  log "Remote checksum: $REMOTE_SUM"
  exit 1
fi

# Cleanup local temporary archive
rm -f "$ARCHIVE"

log "Backup completed successfully."
