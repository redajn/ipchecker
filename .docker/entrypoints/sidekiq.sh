#!/bin/sh
set -e

echo "Waiting for PostgreSQL to be ready..."

until PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT 1 FROM ips LIMIT 1;" > /dev/null 2>&1; do
  sleep 1
done

echo "Starting Sidekiq..."
exec bundle exec sidekiq -r ./sidekiq/initializer.rb -C ./sidekiq/sidekiq.yml
