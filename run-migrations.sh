#!/bin/sh

if [ -z "$DB_USER" ]; then echo "DB_USER not specified" && exit 1; fi
if [ -z "$DB_PASSWORD" ]; then echo "DB_PASSWORD not specified" && exit 1; fi
if [ -z "$DB_HOST" ]; then echo "DB_HOST not specified" && exit 1; fi
if [ -z "$DB_DATABASE" ]; then echo "DB_DATABASE not specified" && exit 1; fi
if [ -z "$REPO" ]; then echo "REPO not specified" && exit 1; fi
if [ -z "$TARGET_VERSION" ]; then echo "TARGET_VERSION not specified" && exit 1; fi

git clone "$REPO" out
cd out || exit 2
git checkout "$REV"

export DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_DATABASE

sqlx migrate run --source "$MIGRATIONS_DIR" --target-version "$TARGET_VERSION"
sqlx migrate revert --source "$MIGRATIONS_DIR" --target-version "$TARGET_VERSION"
