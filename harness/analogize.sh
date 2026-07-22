#!/bin/sh
# analogize.sh: analogy and triangulation queries.
#   analogize.sh A B C            -> A : B :: C : ?
#   analogize.sh -t S1 S2 [...]   -> invariant + matches
set -eu
DIR="$(dirname "$0")"
case "${1:-}" in
  -t) shift
      [ $# -ge 2 ] || { echo "usage: analogize.sh -t S1 S2 [...]"; exit 2; }
      exec "$DIR/run.sh" triangulate "$@" ;;
  *)  [ $# -ge 3 ] || { echo "usage: analogize.sh A B C"; exit 2; }
      exec "$DIR/run.sh" analogy "$@" ;;
esac
