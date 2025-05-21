#!/bin/sh

if [ -z "$DATABASE_URL" ]; then echo "DATABASE_URL not specified" && exit 1; fi
if [ -z "$REPO" ]; then echo "REPO not specified" && exit 1; fi
if [ -z "$TARGET_VERSION" ]; then echo "TARGET_VERSION not specified" && exit 1; fi

git clone "$REPO" out
cd out || exit 2
git checkout "$REV"

sqlx migrate run --source "$MIGRATIONS_DIR" --target-version "$TARGET_VERSION"
sqlx migrate revert --source "$MIGRATIONS_DIR" --target-version "$TARGET_VERSION"
