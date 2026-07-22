# The 29 Relationship Types: Working Definitions

These are the locked 29. This file records what each type means
mathematically, what the Curry core can decide today, and what is
delegated to the geometry helper. Definitions may deepen; the set
may not change without operator instruction. OPERATOR: WHO TF SAID MATH DEFINED THIS

Verdict semantics (Metrics.curry): `Confirmed` means the
structural evidence in the coordinates decides it. `Candidate`
means the structure is compatible but certification needs smooth
machinery the Curry side does not carry. `Absent` means the
evidence rules it out.

## 11 Morphisms

**Isomorphic.** Bijective structure-preserving map. Implemented:
identical skeletons (structure with scalars erased) and equal
leaf multisets, so labels may permute but nothing is lost.

**Isometric.** Distance-preserving map. Implemented: identical
skeletons and matching successive-gap spectra of sorted leaves;
translation-invariant, so a shifted copy confirms.

**Homomorphic.** Structure-preserving, not necessarily bijective.
Implemented: one skeleton embeds in the other (sub-shape match).

**Homeomorphic.** Topological equivalence: connectivity preserved
under stretching, no tearing. Implemented on the discrete
topology signature (graph node/edge counts, lattice order size,
grid arity, chain node counts). The helper's `components` and
`degree-profile` kernels refine this.

**Diffeomorphic.** Smooth invertible map with smooth inverse.
Candidate on skeleton match; certification requires the
differential structure (helper kernels over sampled charts).

**Symplectic.** Phase-space and information-density preserving.
Candidate on skeleton match; certification requires the 2-form,
which needs the helper's tensor machinery.

**Holomorphic.** Angle-preserving (conformal). Candidate on
skeleton match; certification via the helper on sampled charts.

**Automorphic.** A shape maps onto a proper sub-part of itself:
the fractal property. Implemented: a strict sub-skeleton embeds
the whole skeleton.

**Endomorphic.** Self-mapping within a closed boundary.
Implemented conservatively: the skeleton embeds in itself and the
pair shares one skeleton (recursion-compatible).

**Homothetic.** Uniform scaling from a fixed center. Implemented:
one uniform ratio k (k /= 1) across all leaf pairs.

**Anisometric.** Uneven scaling across dimensions, continuity
kept. Implemented: same skeleton, differing leaf values, and no
uniform ratio.

## 7 Routings

Routings classify how signal travels between two seeds through
the rhizome. They are read off diffusion results and coordinate
structure, never off a walked path.

**Lineal.** One seed's coordinate structurally contains the
other's on a recursive axis (depth differs by containment).

**Siblial.** Both resonate strongly with a common third seed at
one step, and their coordinates on shared axes are near.

**Collateral.** Shared resonance source further out than one
step; related through ancestry of signal, not adjacency.

**Tangential.** Coordinate-space proximity without rhizome
resonance: near-miss. They pass through the same region and never
touch.

**Convergent.** Ray coordinates whose directions point into the
same region: approaching from different origins.

**Divergent.** Strong shared origin (both connect to a common
seed) with coordinate distance growing along their rays.

**Orthogonal.** Nonzero resonance at the diffusion horizon and
minimal everywhere earlier: the faintest signal, the longest way
around, still connected.

## 5 Measures

**Geodesic.** Shortest path length through the curved manifold.
Today: chord length via the helper's `chord` kernel; true
geodesics arrive with the manifolds package wiring.

**Density.** Count of wojaks populating the region between two
seeds (coordinate-space ellipsoid on shared axes).

**Curvature.** How much the manifold bends between them. Helper
kernels: `curvature` (sampled path turning) and
`triangle-excess` (angle-sum deviation from flat).

**Resonance.** Accumulated diffusion mass reaching one seed from
a query at the other. Implemented in Query.curry; conserved mass,
decay 0.5, conductance-weighted.

**Depth.** Difference in recursive embedding layers
(`coordDepth`) between their coordinates on shared axes.

## 3 Antithets

**Inverse.** A undoes B: composing their transformations
approximates identity. Detect: deltas on shared axes cancel.

**Complement.** A fills exactly what B lacks: their coordinate
supports are disjoint and their union completes a shape that
matches a known invariant.

**Antipodal.** Maximally distant on a shared axis while both
participate in it. Not unrelated (that is orthogonal): actively
opposite.

## 2 Directions

**Immanent.** The relationship lives inside both coordinates: it
is visible in each one alone (shared sub-shape present in both).
No rhizome travel needed to see it.

**Transcendent.** The relationship only exists from above:
neither coordinate contains it; it appears only in the invariant
extracted across them (anti-unification yields structure neither
holds alone).

## 1 Mother Of Is

**Isness.** The ground state. Every seed carries the isness
coordinate and a connection to the mother seed. Near isness all
things are equidistant; curvature grows with specificity. Not a
morphism, routing, measure, antithet, or direction: the fact of
existence connecting to the fact of existence.
