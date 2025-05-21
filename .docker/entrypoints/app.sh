#!/bin/sh

set -e

bundle install --jobs $(nproc)

echo "Waiting for PostgreSQL to be ready..."
until PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d postgres -c '\l' > /dev/null 2>&1; do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done
echo "PostgreSQL is ready!"

echo "Running migrations..."
bundle exec sequel -m db/migrations postgres://$DB_USER:$DB_PASSWORD@$DB_HOST/${DB_NAME}

echo "Creating test database..."
if ! PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}_test'" | grep -q 1; then
  PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d postgres -c "CREATE DATABASE ${DB_NAME}_test WITH TEMPLATE ${DB_NAME};"
fi

echo "Starting server..."
rm -f /tmp/puma.pid
bundle exec puma --pidfile /tmp/puma.pid -C config/puma.rb
