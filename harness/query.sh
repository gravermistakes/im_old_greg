#!/bin/sh
# query.sh: diffuse signal from a seed and read the field.
#   query.sh SEED [steps]
set -eu
DIR="$(dirname "$0")"
[ $# -ge 1 ] || { echo "usage: query.sh SEED [steps]"; exit 2; }
exec "$DIR/run.sh" query "$@"
