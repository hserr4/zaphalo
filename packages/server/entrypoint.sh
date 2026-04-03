#!/bin/sh
set -e

echo "🚀 Zaphalo Server entrypoint started..."

setup_and_migrate_db() {
    echo "🔍 Parsing database connection..."
    
    # Extract components from PG_DATABASE_URL
    PGUSER=$(echo $PG_DATABASE_URL | awk -F '//' '{print $2}' | awk -F ':' '{print $1}')
    PGPASS=$(echo $PG_DATABASE_URL | awk -F ':' '{print $3}' | awk -F '@' '{print $1}')
    PGHOST=$(echo $PG_DATABASE_URL | awk -F '@' '{print $2}' | awk -F ':' '{print $1}')
    PGPORT=$(echo $PG_DATABASE_URL | awk -F ':' '{print $4}' | awk -F '/' '{print $1}')
    PGDATABASE=$(echo $PG_DATABASE_URL | awk -F '/' '{print $NF}' | cut -d'?' -f1)

    echo "⏳ Waiting for database at ${PGHOST}:${PGPORT}..."
    
    # Wait for database to be ready
    MAX_RETRIES=30
    COUNT=0
    until PGPASSWORD=${PGPASS} psql -h ${PGHOST} -p ${PGPORT} -U ${PGUSER} -d postgres -c '\q' > /dev/null 2>&1; do
      COUNT=$((COUNT + 1))
      if [ $COUNT -gt $MAX_RETRIES ]; then
        echo "❌ Error: Database connection timed out after ${MAX_RETRIES} attempts."
        exit 1
      fi
      echo "📡 Database is unavailable - sleeping (Attempt $COUNT/$MAX_RETRIES)"
      sleep 2
    done

    echo "✅ Database is up! Checking for ${PGDATABASE}..."
    
    # Creating the database if it doesn't exist
    db_count=$(PGPASSWORD=${PGPASS} psql -h ${PGHOST} -p ${PGPORT} -U ${PGUSER} -d postgres -tAc "SELECT COUNT(*) FROM pg_database WHERE datname = '${PGDATABASE}'")
    
    if [ "$db_count" = "0" ]; then
        echo "🔨 Database ${PGDATABASE} does not exist, creating..."
        PGPASSWORD=${PGPASS} psql -h ${PGHOST} -p ${PGPORT} -U ${PGUSER} -d postgres -c "CREATE DATABASE \"${PGDATABASE}\""

        echo "📦 Running setup scripts and initial migrations..."
        NODE_OPTIONS="--max-old-space-size=1500" tsx ./scripts/setup-db.ts
        yarn database:migrate:run
    fi
    
    echo "🔄 Running production upgrade commands..."
    yarn command:prod upgrade
    echo "✨ Successfully prepared database!"
}

register_background_jobs() {
    if [ "${DISABLE_CRON_JOBS_REGISTRATION}" = "true" ]; then
        echo "⏭️ Cron job registration is disabled, skipping..."
        return
    fi
  
    echo "⏰ Registering background sync jobs..."
    if yarn command:prod cron:register:all; then
        echo "✅ Successfully registered all background sync jobs!"
    else
        echo "⚠️ Warning: Failed to register background jobs, but continuing startup..."
    fi
}

setup_and_migrate_db
register_background_jobs

echo "🏁 Starting Zaphalo application..."
# Continue with the original Docker command
exec "$@"
