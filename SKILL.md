---
name: im-old-greg
description: Use the IM OLD GREG field to store entities as wojaks, place typed coordinates on shared axes, and run shape queries (similarity, analogy, triangulation) across any domain. Trigger when work involves finding structural patterns that recur across contexts, cross-domain analogy, or the .greg field format.
---

# IM OLD GREG: field operations for agents

You have two binaries (from GitHub Releases or a local build):
`greg` (the Curry core) and `greg-geom` (transport + numeric
kernels). The harness scripts in `harness/` wire them; prefer the
harness over raw pipes.

## Setup

```
export GREG_FIELD=./data.greg     # where the field lives
sh harness/run.sh init            # create an empty field
sh harness/run.sh seed-axes       # optional: 120-axis starter atlas
```

## Growing the field

```
sh harness/ingest.sh dolphin trophic-level=3 streamlining=0.9
sh harness/run.sh connect dolphin sardine predation
sh harness/run.sh set-coord dolphin habitat 1,0.5,0.2
```

Every wojak automatically connects to isness. Seeds are identity:
reusing a seed accretes onto the same wojak, never replaces it.

## Asking questions

```
sh harness/query.sh dolphin 4        # diffusion from a seed
sh harness/relate.sh dolphin shark   # morphism verdicts
sh harness/analogize.sh a b c        # a : b :: c : ?
sh harness/analogize.sh -t x y z     # invariant + matches
sh harness/suggest.sh                # what the field needs
```

`greg types` prints the 29 locked relationship types; if that
number is ever not 29, stop and report.

## Rules that bind you here

- Coordinates are typed (scalar through manifold) and nest.
  Never flatten them. Never cap dimensions.
- Memos and pepos describe; they never own. Axes belong to no
  memo. Do not build hierarchy into the field.
- Queries diffuse; they do not traverse. Do not bolt graph-walk
  algorithms onto the rhizome.
- The .greg file is append-only binary CBOR. Do not edit it by
  hand; go through the binary. `greg-geom validate < file.greg`
  checks integrity.
- No JSON. External data enters as CBOR or as CLI arguments.

## Interpreting output

`relate` verdicts: Confirmed is structural fact; Candidate means
smooth-morphism compatible but uncertified; Absent is ruled out.
`analogy` mismatch scores: lower is better, 0 is exact. `chores`
is the field reporting its own thin spots; act on them or
surface them to the operator.
