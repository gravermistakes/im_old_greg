#!/bin/sh
# Seed a harmonic series and the components that make it possible.
# The harmonic series is the exemplary wojak: it has the most axes.
# All components connect back to it; it is the topology's center.
#
# Run from repo root: sh reference/seed_harmonic_components.sh
set -eu
cd "$(dirname "$0")/.."

sh harness/run.sh init
sh harness/run.sh seed-axes

# ---- exemplary wojak: the harmonic series itself ----
# Seeded first. Has the most axes of any wojak in the field.
# harmonic-structure holds the canonical 1/n amplitude series as a vector.

sh harness/ingest.sh harmonic-series \
  periodicity=0.95 \
  phase-coherence=0.95 \
  harmonic-structure=1.0,0.5,0.33,0.25,0.2,0.17 \
  multiplicity=0.9 \
  intensity=0.8 \
  saturation-ratio=0.85 \
  cycle-stability=0.9 \
  cardinality=0.8 \
  concentration-density=0.7 \
  phase-locking=0.9 \
  connectivity=0.9 \
  state-persistence=0.85 \
  magnitude=0.7 \
  scale=0.5 \
  change-rate=0.3

# ---- physical components ----

sh harness/ingest.sh vibrating-body \
  intensity=0.85 \
  change-rate=0.75 \
  periodicity=0.5 \
  state-persistence=0.6 \
  velocity=0.7 \
  harmonic-structure=1.0,0.5,0.33

sh harness/ingest.sh medium \
  connectivity=0.8 \
  concentration-density=0.6 \
  penetration-degree=0.75 \
  state-persistence=0.5 \
  persistence=0.7 \
  periodicity=0.4

sh harness/ingest.sh boundary-condition \
  closure-degree=0.9 \
  closure-permeability=0.1 \
  persistence=0.95 \
  state-persistence=0.95 \
  edge-sharpness=0.8 \
  cardinality=0.5

sh harness/ingest.sh standing-wave \
  periodicity=1.0 \
  intensity=0.8 \
  state=0.7 \
  phase-coherence=0.95 \
  position=0.5 \
  harmonic-structure=1.0,0.5,0.33,0.25

sh harness/ingest.sh resonance \
  intensity=0.9 \
  saturation-ratio=0.85 \
  phase-locking=0.9 \
  change-rate=0.8 \
  periodicity=0.5 \
  harmonic-structure=1.0,0.5,0.33

# ---- mathematical components ----

sh harness/ingest.sh fundamental-frequency \
  periodicity=0.5 \
  intensity=0.3 \
  scale=0.2 \
  cycle-stability=0.95 \
  cardinality=1.0

sh harness/ingest.sh integer-multiple \
  multiplicity=0.6 \
  cardinality=0.5 \
  velocity=0.4 \
  scale=0.5

sh harness/ingest.sh periodicity \
  periodicity=0.8 \
  cycle-stability=0.7 \
  phase-coherence=0.6 \
  state-persistence=0.75

sh harness/ingest.sh amplitude \
  intensity=0.4 \
  magnitude=0.4 \
  saturation-ratio=0.5 \
  scale=0.4

sh harness/ingest.sh superposition \
  multiplicity=0.8 \
  intensity=0.7 \
  harmonic-structure=0.1,0.2,0.3,0.4 \
  phase-coherence=0.85 \
  concentration-density=0.65

# ---- connections: harmonic-series -> components ----
# The series is the structural whole; each component participates in it.

sh harness/run.sh connect harmonic-series vibrating-body Transcendent
sh harness/run.sh connect harmonic-series medium Transcendent
sh harness/run.sh connect harmonic-series boundary-condition Immanent
sh harness/run.sh connect harmonic-series standing-wave Isomorphic
sh harness/run.sh connect harmonic-series resonance Homomorphic
sh harness/run.sh connect harmonic-series fundamental-frequency Lineal
sh harness/run.sh connect harmonic-series integer-multiple Lineal
sh harness/run.sh connect harmonic-series periodicity Isomorphic
sh harness/run.sh connect harmonic-series amplitude Homothetic
sh harness/run.sh connect harmonic-series superposition Isomorphic

# ---- connections: physical ----

sh harness/run.sh connect vibrating-body medium Immanent
sh harness/run.sh connect medium boundary-condition Convergent
sh harness/run.sh connect boundary-condition standing-wave Immanent
sh harness/run.sh connect vibrating-body standing-wave Homomorphic
sh harness/run.sh connect standing-wave resonance Isomorphic
sh harness/run.sh connect vibrating-body resonance Homomorphic

# ---- connections: mathematical ----

sh harness/run.sh connect fundamental-frequency integer-multiple Lineal
sh harness/run.sh connect fundamental-frequency periodicity Homomorphic
sh harness/run.sh connect fundamental-frequency amplitude Homothetic
sh harness/run.sh connect integer-multiple periodicity Convergent
sh harness/run.sh connect integer-multiple superposition Convergent
sh harness/run.sh connect amplitude superposition Convergent
sh harness/run.sh connect periodicity superposition Homeomorphic

# ---- connections: physical <-> mathematical ----

sh harness/run.sh connect vibrating-body fundamental-frequency Isomorphic
sh harness/run.sh connect boundary-condition integer-multiple Lineal
sh harness/run.sh connect standing-wave superposition Isomorphic
sh harness/run.sh connect medium periodicity Homomorphic
sh harness/run.sh connect resonance amplitude Homothetic
