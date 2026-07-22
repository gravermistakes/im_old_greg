#!/bin/sh
# relate.sh: morphism verdicts and relatedness for a seed pair.
#   relate.sh A B
set -eu
DIR="$(dirname "$0")"
[ $# -ge 2 ] || { echo "usage: relate.sh A B"; exit 2; }
exec "$DIR/run.sh" relate "$@"
