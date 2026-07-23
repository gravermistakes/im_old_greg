#!/bin/sh
# run.sh: CLI entry point for im-old-greg.
# Owns the file boundary: .greg files stay byte-exact binary on
# disk; the greg binary speaks hex CBOR on its pipes; greg-geom
# converts between the two.
#
#   GREG_FIELD  path to the .greg field file (default ./data.greg)
#   GREG_BIN    path to the greg binary      (default: greg on PATH)
#   GREG_GEOM   path to the greg-geom helper (default: greg-geom)
set -eu

FIELD="${GREG_FIELD:-./data.greg}"
BIN="${GREG_BIN:-greg}"
GEOM="${GREG_GEOM:-greg-geom}"

usage() {
  "$BIN" help
  echo ""
  echo "harness: GREG_FIELD=$FIELD"
  exit 0
}

[ $# -ge 1 ] || usage
cmd="$1"

# commands that rewrite the field
mutates() {
  case "$1" in
    init|add|connect|set-coord|compact) return 0 ;;
    *) return 1 ;;
  esac
}

field_hex() {
  if [ -f "$FIELD" ]; then
    "$GEOM" bin2hex < "$FIELD"
  else
    printf ''
  fi
}

if mutates "$cmd"; then
  out=$(field_hex | "$BIN" "$@")
  tmp="$FIELD.tmp.$$"
  printf '%s' "$out" | "$GEOM" hex2bin > "$tmp"
  mv "$tmp" "$FIELD"
  echo "field written: $FIELD"
else
  field_hex | "$BIN" "$@"
fi
