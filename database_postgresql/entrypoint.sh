#!/bin/bash
set -euo pipefail

# Map container ENV to the scripts' expected variables
export DB_NAME="${POSTGRES_DB:-myapp}"
export DB_USER="${POSTGRES_USER:-appuser}"
export DB_PASSWORD="${POSTGRES_PASSWORD:-dbuser123}"
export DB_PORT="${DB_PORT:-5000}"

echo "Container entrypoint starting..."
echo "Using DB: ${DB_NAME}, User: ${DB_USER}, Port: ${DB_PORT}"

# Ensure scripts are executable (in case of mount or override)
chmod +x /app/startup.sh /app/restore_db.sh /app/backup_db.sh || true

# The provided startup.sh uses full paths and sudo, which aren't needed inside this container.
# We'll adapt by setting PG_BIN path based on the image
PG_BIN="/usr/lib/postgresql/$(ls /usr/lib/postgresql/ | head -1)/bin"
export PG_BIN

# Prepare data directory if not present
if [ ! -f "/var/lib/postgresql/data/PG_VERSION" ]; then
  echo "Initializing PostgreSQL data directory..."
  # Initialize database cluster
  /usr/local/bin/docker-entrypoint.sh postgres &>/dev/null || true
fi

# Start postgres temporarily to allow startup.sh to configure
# We will run our startup script which starts and configures on the desired port.
cd /app

# Some commands in startup.sh use 'sudo -u postgres'; we're already the postgres user in this container.
# Add shim to make 'sudo -u postgres <cmd>' behave like '<cmd>' to avoid failures.
sudo() {
  if [ "$1" = "-u" ] && [ "$2" = "postgres" ]; then
    shift 2
  fi
  "$@"
}

# Run the startup (sets up DB, user, permissions, and writes connection files)
./startup.sh

# If a backup file exists, perform a restore
if [ -f "/app/database_backup.sql" ] || [ -f "/app/database_backup.db" ] || [ -f "/app/database_backup.archive" ]; then
  echo "Backup file detected - attempting restore..."
  ./restore_db.sh || echo "Restore script completed with non-zero exit, continuing..."
else
  echo "No backup present - skipping restore."
fi

echo "Database container setup complete. Bringing postgres to foreground..."

# Finally, exec the postgres server in the foreground on the configured port
exec postgres -D /var/lib/postgresql/data -p "${DB_PORT}"
