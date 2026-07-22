#!/bin/sh
# ingest.sh: grow wojaks into the field.
#   ingest.sh SEED [axis=value ...]
# Every wojak connects to isness on arrival. Pepos and memos are
# not ingested: they are descriptions, and descriptions are
# computed, not stored.
set -eu
DIR="$(dirname "$0")"
[ $# -ge 1 ] || { echo "usage: ingest.sh SEED [axis=value ...]"; exit 2; }
exec "$DIR/run.sh" add "$@"
