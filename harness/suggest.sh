#!/bin/sh
# suggest.sh: ask the field what it needs.
set -eu
DIR="$(dirname "$0")"
exec "$DIR/run.sh" chores
