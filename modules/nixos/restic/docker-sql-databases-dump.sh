#!/usr/bin/env bash

# Configuration
APPS_ROOT="/home/app-manager/applications"
DATE_FORMAT="+%Y-%m-%d %H:%M:%S"

# Helper function for logging
log() {
  local level="$1"
  local message="$2"
  echo "[$(date "$DATE_FORMAT")] [$level] $message"
}

# 1. Check Docker Access
if ! docker info >/dev/null 2>&1; then
  log "ERROR" "Docker is not running or current user cannot access docker socket."
  exit 1
fi

log "INFO" "Starting database dump process in $APPS_ROOT"

# 2. Iterate through all subdirectories
find "$APPS_ROOT" -mindepth 1 -maxdepth 1 -type d | sort | while read -r app_dir; do

  APP_NAME=$(basename "$app_dir")
  COMPOSE_FILE=""

  # Check for docker-compose.yml or docker-compose.yaml
  if [[ -f "$app_dir/docker-compose.yml" ]]; then
    COMPOSE_FILE="docker-compose.yml"
  elif [[ -f "$app_dir/docker-compose.yaml" ]]; then
    COMPOSE_FILE="docker-compose.yaml"
  else
    # Silently skip directories without compose files (unless you want to log these too)
    continue
  fi

  # Navigate to directory
  cd "$app_dir" || continue

  # 3. Find Containers
  # We use a flag to track if we found any DBs in this specific app
  DB_FOUND_IN_APP=false

  # Get running services
  SERVICES=$(docker compose ps --format '{{.Service}}|{{.Image}}|{{.Name}}' 2>/dev/null)

  if [[ -z "$SERVICES" ]]; then
    log "WARN" "[$APP_NAME] No running containers found (checked $COMPOSE_FILE)."
    continue
  fi

  # Process each service
  while IFS='|' read -r service image container; do
    # Skip empty lines
    [[ -z "$container" ]] && continue

    OUTPUT_FILE="$app_dir/${service}.sql"
    ERROR_LOG="/tmp/${container}_error.log"
    DUMPED=false

    # --- STRATEGY: POSTGRESQL ---
    if [[ "$image" == *"postgres"* ]] || [[ "$image" == *"pgvecto-rs"* ]] || [[ "$image" == *"timescale"* ]]; then
      log "INFO" "[$APP_NAME] Found PostgreSQL service: $service"
      DB_FOUND_IN_APP=true

      # Detect DB User (Default to 'postgres')
      DB_USER=$(docker exec "$container" printenv POSTGRES_USER)
      [[ -z "$DB_USER" ]] && DB_USER="postgres"

      # Detect Password
      DB_PASS=$(docker exec "$container" printenv POSTGRES_PASSWORD)

      # RUN DUMP
      if docker exec -e PGPASSWORD="$DB_PASS" -u postgres "$container" pg_dumpall --clean --if-exists -U "$DB_USER" >"$OUTPUT_FILE" 2>"$ERROR_LOG"; then
        DUMPED=true
      else
        log "ERROR" "[$APP_NAME] Failed to dump $container. Reason: $(head -n 1 "$ERROR_LOG")"
        rm -f "$OUTPUT_FILE"
      fi
      rm -f "$ERROR_LOG"

    # --- STRATEGY: MARIADB / MYSQL ---
    elif [[ "$image" == *"mariadb"* ]] || [[ "$image" == *"mysql"* ]]; then
      log "INFO" "[$APP_NAME] Found MariaDB/MySQL service: $service"
      DB_FOUND_IN_APP=true

      # Detect Password
      DB_PASS=$(docker exec "$container" printenv MYSQL_ROOT_PASSWORD)
      [[ -z "$DB_PASS" ]] && DB_PASS=$(docker exec "$container" printenv MARIADB_ROOT_PASSWORD)

      if [[ -n "$DB_PASS" ]]; then
        # Determine command
        DUMP_CMD=""
        if docker exec "$container" sh -c "type mariadb-dump" >/dev/null 2>&1; then
          DUMP_CMD="mariadb-dump"
        elif docker exec "$container" sh -c "type mysqldump" >/dev/null 2>&1; then
          DUMP_CMD="mysqldump"
        fi

        if [[ -z "$DUMP_CMD" ]]; then
          log "ERROR" "[$APP_NAME] Neither 'mariadb-dump' nor 'mysqldump' found in container $container."
          continue
        fi

        # RUN DUMP
        if docker exec "$container" sh -c "export MYSQL_PWD='$DB_PASS'; $DUMP_CMD -u root --all-databases --single-transaction --skip-dump-date" >"$OUTPUT_FILE" 2>"$ERROR_LOG"; then
          DUMPED=true
        else
          log "ERROR" "[$APP_NAME] Failed to dump $container. Reason: $(head -n 1 "$ERROR_LOG")"
          rm -f "$OUTPUT_FILE"
        fi
        rm -f "$ERROR_LOG"
      else
        log "WARN" "[$APP_NAME] Skipping $container: No ROOT password variable found."
      fi
    fi

    # Print success message with size if dumped
    if [ "$DUMPED" = true ]; then
      FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
      log "INFO" "[$APP_NAME] Backup successful: $OUTPUT_FILE (Size: $FILE_SIZE)"
    fi

  done <<<"$SERVICES"

  # Log if no database was found in this app
  if [ "$DB_FOUND_IN_APP" = false ]; then
    log "INFO" "[$APP_NAME] No database container detected."
  fi

done

log "INFO" "Database dump process complete."
