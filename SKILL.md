---
name: im-old-greg
description: Use the IM OLD GREG field to store concepts as wojaks, place on shared axes, and run shape queries (similarity, analogy, triangulation). Trigger when work involves finding structural patterns that recur across contexts, cross-domain analogy, or the .greg field format.
---

# IM OLD GREG: field operations for agents

You have two binaries (from GitHub Releases or a local build):
`greg` (the fieldcore) and `greg-geom` (transport + numeric
kernels).

## Setup

Download the latest `greg` and `greg-geom` binaries from the GitHub
Releases page and put them on PATH. Then:

```sh
export GREG_FIELD=./data.greg
sh harness/run.sh init      # emit an empty field
sh harness/run.sh add isness
```

`greg types` must print exactly 29 relationship types. If it does not,
stop and report before doing anything else.

## Growing the field

Every wojak automatically connects to the axis of isness. Seeds are identity: reusing a seed accretes onto the same wojak, never replaces it.

## Asking questions

The query language is Curry, not Bash. The harness translates CLI
commands to hex CBOR on stdin/stdout; the binary does the reasoning.

`greg types` prints the 29 locked relationship types; if that
number is ever not 29, stop and report.

## Rules that bind you here

- Coordinates are typed and nest in stochastic fractals. Never flatten them. Never cap dimensions.
- Memos and pepos describe; they never own. Axes belong to no memo. Do not build hierarchy into the field.
- Queries diffuse; they do not traverse. Do not bolt graphwalk algorithms onto the rhizome.
- The .greg file is append-only binary CBOR. Do not edit it by hand; go through the binary. `greg-geom validate < file.greg` checks integrity.
- No JSON. External data enters as CBOR or as CLI arguments.

## Interpreting output

`relate` verdicts: Confirmed is structural fact; Candidate means smooth-morphism compatible but uncertified; Absent is ruled out.
`analogy` mismatch scores: lower is better, 0 is exact.
`advisory` is the field reporting its own thin spots; act on them or surface them to the operator.
