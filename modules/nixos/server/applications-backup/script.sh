#!/usr/bin/env bash
set -uo pipefail

S3_BUCKET_NAME="${S3_BUCKET_NAME}"
S3_ENDPOINT="${S3_ENDPOINT}"
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
APPS_DIR="${APPS_DIR:-/home/app-manager/applications}"
MAX_SIZE_MB=1000

log_with_timestamp() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1"
}

handle_error() {
  log_with_timestamp "ERROR: $1"
}

DAY_OF_WEEK=$(date +"%u")
if [ "$DAY_OF_WEEK" -eq 7 ]; then
  LIFECYCLE="weekly"
else
  LIFECYCLE="daily"
fi

S3_TARGET="s3://$S3_BUCKET_NAME/$LIFECYCLE"

for APP_DIR in "$APPS_DIR"/*; do
  [ -d "$APP_DIR" ] || continue

  APP_NAME=$(basename "$APP_DIR")
  log_with_timestamp "$APP_NAME: Starting backup..."

  TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")
  BACKUP_FILENAME="$APP_NAME-$TIMESTAMP"
  BACKUP_FILEPATH="$APP_DIR/$BACKUP_FILENAME.tar.gz"

  TMP_DIR=$(mktemp -d)
  chmod 755 "$TMP_DIR"
  mkdir -p "$TMP_DIR/$BACKUP_FILENAME/source"

  while IFS= read -r -d '' ITEM; do
    ITEM_BASENAME=$(basename "$ITEM")

    if [[ "$ITEM_BASENAME" == *.tar.gz ]]; then
      continue
    fi

    if [ -d "$ITEM" ]; then
      SUBDIR_SIZE_MB=$(du -sm "$ITEM" 2>/dev/null | cut -f1)
      if [ "$SUBDIR_SIZE_MB" -le "$MAX_SIZE_MB" ]; then
        cp -a "$ITEM" "$TMP_DIR/$BACKUP_FILENAME/source/" 2>/dev/null ||
          log_with_timestamp "$APP_NAME: Skipping directory '$ITEM_BASENAME' due to permission error"
      else
        log_with_timestamp "$APP_NAME: Skipping subdirectory '$ITEM_BASENAME' (size > ${MAX_SIZE_MB}MB)"
      fi
    else
      cp -a "$ITEM" "$TMP_DIR/$BACKUP_FILENAME/source/" 2>/dev/null ||
        log_with_timestamp "$APP_NAME: Skipping file '$ITEM_BASENAME' due to permission error"
    fi
  done < <(find "$APP_DIR" -mindepth 1 -maxdepth 1 -print0)

  if [ -f "$APP_DIR/.backup" ]; then
    COMPOSE_ARGS=()
    for FILE in "$APP_DIR"/docker-compose*.yml; do
      [ -f "$FILE" ] && COMPOSE_ARGS+=("-f" "$FILE")
    done

    if [ ${#COMPOSE_ARGS[@]} -eq 0 ]; then
      log_with_timestamp "$APP_NAME: No docker-compose files found, skipping volume backup..."
    else
      ALL_VOLUMES_JSON=$(docker compose "${COMPOSE_ARGS[@]}" config --format json 2>/dev/null || true)
      ALL_VOLUMES_ARRAY=()

      if [ -n "$ALL_VOLUMES_JSON" ]; then
        while IFS= read -r volumeName || [ -n "$volumeName" ]; do
          ALL_VOLUMES_ARRAY+=("$volumeName")
        done < <(echo "$ALL_VOLUMES_JSON" | jq -r '.volumes[].name // empty' 2>/dev/null)
      fi

      if [ ${#ALL_VOLUMES_ARRAY[@]} -eq 0 ]; then
        log_with_timestamp "$APP_NAME: No volumes declared in compose config..."
      else
        BACKUP_HAS_WILDCARD=false
        VOLUMES_TO_BACKUP=()

        while IFS= read -r line || [ -n "$line" ]; do
          if [ "$line" = "*" ]; then
            BACKUP_HAS_WILDCARD=true
            break
          else
            VOLUMES_TO_BACKUP+=("$line")
          fi
        done <"$APP_DIR/.backup"

        if [ "$BACKUP_HAS_WILDCARD" = true ]; then
          VOLUMES_TO_BACKUP=("${ALL_VOLUMES_ARRAY[@]}")
        fi

        if [ ${#VOLUMES_TO_BACKUP[@]} -gt 0 ]; then
          mkdir -p "$TMP_DIR/$BACKUP_FILENAME/volumes"
          for VOLUME in "${VOLUMES_TO_BACKUP[@]}"; do
            log_with_timestamp "$APP_NAME: Backing up volume '$VOLUME'..."
            if ! docker run --rm \
              -v "$VOLUME":/source \
              -v "$TMP_DIR/$BACKUP_FILENAME/volumes":/backup \
              busybox sh -c "cp -a /source /backup/$VOLUME && chown -R $(id -u):$(id -g) /backup/$VOLUME" 2>&1; then
              log_with_timestamp "$APP_NAME: Failed to backup volume '$VOLUME'"
            fi
          done
        fi
      fi
    fi
  else
    log_with_timestamp "$APP_NAME: No .backup file found, skipping volume backup..."
  fi

  log_with_timestamp "$APP_NAME: Creating archive..."
  if ! (cd "$TMP_DIR" && tar -czf "$BACKUP_FILEPATH" "$BACKUP_FILENAME" 2>&1); then
    handle_error "$APP_NAME: Failed to create archive"
    rm -rf "$TMP_DIR"
    continue
  fi

  ARCHIVE_SIZE=$(du -h "$BACKUP_FILEPATH" | cut -f1)
  log_with_timestamp "$APP_NAME: Uploading $ARCHIVE_SIZE to S3..."
  if ! aws s3 cp "$BACKUP_FILEPATH" "$S3_TARGET/$APP_NAME/" \
    --endpoint-url="$S3_ENDPOINT" --quiet 2>/dev/null; then
    handle_error "$APP_NAME: Failed to upload to S3"
    rm -rf "$TMP_DIR"
    continue
  fi

  find "$APP_DIR" -type f -name "$APP_NAME-*.tar.gz" ! -name "$BACKUP_FILENAME.tar.gz" -delete

  rm -rf "$TMP_DIR"

  log_with_timestamp "$APP_NAME: Backup complete."
done

log_with_timestamp "All backups completed."
