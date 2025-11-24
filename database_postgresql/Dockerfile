# syntax=docker/dockerfile:1
FROM postgres:16-bookworm

# Set environment variables (can be overridden by .env at runtime)
ENV POSTGRES_DB=myapp \
    POSTGRES_USER=appuser \
    POSTGRES_PASSWORD=dbuser123 \
    DB_PORT=5000

# Create app directory and set as working directory
WORKDIR /app

# Copy scripts and assets into image
COPY startup.sh restore_db.sh backup_db.sh database_backup.sql db_connection.txt post_process_status.lock ./
# Optional visualizer env (not used in container start)
COPY db_visualizer/postgres.env ./db_visualizer/postgres.env

# Ensure scripts are executable
RUN chmod +x /app/startup.sh /app/restore_db.sh /app/backup_db.sh

# Expose the custom DB port used by the scripts
EXPOSE 5000

# Copy an entrypoint wrapper that runs DB init and optional restore
# We avoid sudo usage inside the container; postgres base image runs as postgres user by default for commands.
# This wrapper will adapt to container environment.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to root to adjust permissions on /var/lib/postgresql if needed
USER root
RUN mkdir -p /var/lib/postgresql/data && chown -R postgres:postgres /var/lib/postgresql

# Back to postgres user provided by base image
USER postgres

# Use our entrypoint wrapper which will start postgres on the desired port and then optionally restore data
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
