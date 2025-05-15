#!/bin/sh

set -e

bundle install --jobs $(nproc)

echo "Waiting for PostgreSQL to be ready..."
until PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d postgres -c '\l' > /dev/null 2>&1; do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done
echo "PostgreSQL is ready!"

echo "Setting up the database..."
ruby db/schema.rb

if [ -d "db/migrations" ] && [ "$(ls -A db/migrations)" ]; then
  echo "Running migrations..."
  sequel -m db/migrations
else
  echo "No migrations to run."
fi

echo "Creating test database..."
if ! PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}_test'" | grep -q 1; then
  PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d postgres -c "CREATE DATABASE ${DB_NAME}_test WITH TEMPLATE ${DB_NAME};"
fi

echo "Setting up the test database schema..."
RACK_ENV=test ruby db/schema.rb

echo "Starting server..."
rm -f /tmp/puma.pid
bundle exec puma --pidfile /tmp/puma.pid -C config/puma.rb
