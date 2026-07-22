# IM OLD GREG

**Isomorphic Manifold for Object-Likeness Derivation in Generalizable Recursively Embedded Graphings**

A domain-agnostic shape-matching system built on a Riemannian manifold. Finds structural patterns that recur across different contexts, names, scales, and domains. Written in Curry (KiCS2 backend), with Haskell geometry libraries for manifold computation.

## What It Does

Things have shapes. A dolphin and a shark evolved independently but converged on the same hydrodynamic body plan. A platform mascot on 4chan and a platform mascot on Wikipedia are structurally identical despite having no shared history. A sonnet's volta and a bridge's keystone serve the same structural function in their respective forms. A reentrancy pattern in one codebase has the same shape as a reentrancy pattern in an unrelated codebase.

IM OLD GREG finds these convergences. Given known instances of a shape, it extracts what is invariant across them, then searches for other instances of that shape anywhere in the field, across any domain.

## Concepts

### Wojak

The real entity. A wojak is a bundle of ideas and relationships in spatial relation to other ideas and relationships. Wojaks are the ground truth. Everything else is organizational.

A wojak has a **seed**: the irreducible kernel that was true at creation and remains true no matter how the wojak evolves. The seed IS the identity. Not a hash of it. Not a UUID. The seed itself. Everything else — relationships, context, axis positions — accretes around the seed. A dolphin that gains a new relationship to a research paper is not a new dolphin. It is the same dolphin, richer.

### Pepo

A tighter grouping of wojaks that share characteristics. "Dolphins", "4chan Adjacent Memes", "Arch Bridges". Pepos are descriptive clusters, not structural containers. Wojaks create pepos by sharing axis coordinates. Pepos do not own or define anything.

### Memo

The broadest grouping. "Internet Pictography", "Cetacea", "Fermented Foods". Like pepos, memos are descriptive. They describe a region of the field where wojaks tend to cluster. They do not own axes, define structures, or constrain what their wojaks can do.

### Axes

Axes are first-class entities. They exist independently of memos and pepos. Wojaks have coordinates on axes. That is the only structural relationship.

"Trophic Level" is an axis. Dolphins have coordinates on it. So do hawks. So do bass. They are in different memos, but the axis does not care.

"Platform" is an axis — not "digital platforms," but the abstract concept of a base from which something operates. 4chan, the New York Times, an oil derrick, a hunting blind, a political party, a tectonic plate, and a cell membrane are all positions on the Platform axis.

"Fermentation Method" is an axis. Kimchi, yogurt, ruminant digestion, composting, and sewage treatment all have coordinates on it.

Axes are maximally abstract. Wojaks create them by having coordinates on them. Axes belong to no memo.

### Axis Coordinate Types

A wojak's coordinate on an axis is not necessarily a simple value. Coordinates are typed, and the types form a recursive hierarchy:

- **Scalar**: A single value. (Trophic Level = 3)
- **Vector**: Distribution or multi-occupancy. (Habitat = [coastal, pelagic, estuarine])
- **Ray**: Directional, irreversible. (Evolutionary Trajectory)
- **Matrix**: 2D relational structure. (Genetic Expression = genes x conditions)
- **Tensor**: Varies across other dimensions. (Moral Patienthood = f(Ethical Tradition, Cultural Context, Historical Period))
- **Graph**: Network of nodes and edges. (Social Structure = roles connected by relationships)
- **Lattice**: Ordered structure with meets and joins. (Taxonomic Classification)
- **Manifold**: Curved space of possible states. (Phenotypic Landscape)

These types nest recursively. A manifold's points can be tensors whose components are graphs whose nodes carry vectors. There is no limit to nesting depth. Minimum dimensionality is 31 axes, uncapped.

### Isness

The mother seed. The one axis every wojak shares. Before trophic level, before platform, before moral patienthood: the fact that something IS.

Isness is the ground state of the field. The field radiates outward from isness through differentiation. Near isness, all things are equidistant (everything equally exists). Curvature increases as you move outward into specificity.

The rhizome grows from isness. Every seed connects to it, not as a child to a parent but as a thing that exists connecting to the fact of existence.

### The Rhizome

The data structure is not a tree, not a DAG, not a directed graph. It is a rhizomatic network. No hierarchy. No root (except isness). No parent-child. Every seed connects laterally to other seeds.

The rhizome IS the field. Where seeds are dense, the field is intense. Where seeds are sparse, the field is weak. There are no voids, only regions of lower density.

## 29 Relationship Types

### 11 Morphisms
How two wojaks structurally map to each other.

| Morphism | Definition |
|----------|-----------|
| **Isomorphic** | Full structural equivalence, different labels. The core operation. |
| **Isometric** | Distance-preserving. Metric signature between coordinates is identical globally, no distortion. |
| **Homomorphic** | Structure-preserving without requiring bijection. Partial structural match. |
| **Homeomorphic** | Topologically equivalent. Connectivity preserved, stretching allowed, no tearing. |
| **Diffeomorphic** | Smooth, invertible, calculus-preserving. Continuous transformation in both directions with no rupture. |
| **Symplectic** | Information-density and phase-space preserving. No signal loss during transformation. |
| **Holomorphic** | Angle-preserving, no local shearing. Local shape maintained under projection. |
| **Automorphic** | Self-similar. Maps onto a sub-component of itself. The fractal property. |
| **Endomorphic** | Self-mapping within a closed boundary. Recursive loops, self-referential iteration. |
| **Homothetic** | Uniform proportional scaling from a fixed center. Same shape, different magnitude. |
| **Anisometric** | Uneven scaling across dimensions. Warped differently along different axes without breaking continuity. |

### 7 Routings
How you navigate between wojaks through the rhizome.

| Routing | Definition |
|---------|-----------|
| **Lineal** | One sits directly above or below the other on a recursive axis. |
| **Siblial** | Share the same immediate parent at the same depth. |
| **Collateral** | Share a distant ancestor, not an immediate parent. |
| **Tangential** | Pass through the same region without sharing a node. Near-miss. |
| **Convergent** | Approaching the same region from different directions. |
| **Divergent** | Moving apart from a shared origin. |
| **Orthogonal** | Faintest signal, longest path through the rhizome. Maximally distant while still connected. |

### 5 Measures
Quantitative properties of the relationship between two wojaks.

| Measure | Definition |
|---------|-----------|
| **Geodesic** | Shortest path length through the curved manifold. |
| **Density** | How many other wojaks populate the region between them. |
| **Curvature** | How much the manifold bends between them. High curvature means context-dependent relationships. |
| **Resonance** | Signal strength after diffusion. How strongly a query at one reaches the other. |
| **Depth** | How many recursive embedding layers separate them. |

### 3 Antithets
Opposition relationships.

| Antithet | Definition |
|----------|-----------|
| **Inverse** | A undoes B. The mapping reverses. Encryption and decryption. Predator and prey. |
| **Complement** | A fills exactly what B lacks. Together they complete a structure. Lock and key. Question and answer. |
| **Antipodal** | Maximally distant on a shared axis. Not unrelated (that is orthogonal). Actively opposite on a dimension both participate in. Hot and cold. |

### 2 Directions
Between opposition and unity. Perpendicular to each other.

| Direction | Definition |
|-----------|-----------|
| **Immanent** | The relationship exists WITHIN. The connection between A and B is already inside both of them. You do not traverse the rhizome to find it. The dolphin does not relate to water through an edge. Water is immanent in dolphin. |
| **Transcendent** | The relationship exists BEYOND. The connection requires leaving both to see it. The relationship between a sonnet's volta and a bridge's keystone is transcendent. Neither contains the other. The connection only exists from above. |

### 1 Mother Of Is

**Isness.** The ground state. The one relationship every wojak has. Not a morphism, not a routing, not a measure, not an opposition, not a direction. The fact of existence connecting to the fact of existence.

## Relational Engine

IM OLD GREG does not have a single core operation. It performs all relational reasoning over the same field using the same mechanism: narrowing with free variables.

**Similarity**: Given a wojak, find others that share its shape.

**Analogy**: Given "A is to B," find what C is to. Compute the transformation between A and B, project it onto C.

**Triangulation**: Given N known instances of a shape, extract what is invariant across all of them, then search for more instances across any domain.

**Cross-domain transfer**: A shape found in biology can match a shape in music can match a shape in cooking can match a shape in architecture. The system does not care about domain boundaries. Shared axes are the bridge.

All of these are queries with free variables resolved by Curry's narrowing mechanism. There is no separate engine for each operation.

## Storage: .greg (Fractal Content-Addressable Field)

IM OLD GREG uses a custom binary format that unifies the data store and the witness mesh.

**Atomic seeds.** Every wojak's identity is its seed. The seed is immutable. State accretes around it.

**Direction- and cycle-agnostic.** Connections store node_a and node_b with a CBOR context payload. Whether the connection is directed, undirected, or cyclic depends on the embedded graph, not the storage format.

**Rhizomatic.** The data is an unordered set of seeds and an unordered set of connections. No schema. No hierarchy. No indexes. Just growth.

**Witness mesh.** Observations reference N other observations. Not a chain. Not hashed.

```
data.greg:
  Mother seed: "isness"
  Seeds         -- unordered, append-only, never modified
  Connections   -- seed <-> seed + CBOR context, unordered, mutable
  States        -- seed -> current CBOR, mutable, compactable

witness.greg:
  CBOR observations referencing N other observations
```

**Hot/warm/cold attention:**
- Hot: Wojaks within N relational hops of the current query. Fully loaded.
- Warm: Wojaks within 2N hops. Seeds and summaries loaded. Full state on disk.
- Cold: Everything else. Seed persists. Reachable only when a query wakes it up.

Eviction is by relational distance from current attention, not by age.

**Record format:**

```
Header:
  magic: "IMOLDGREG"
  version: 1
  payload_encoding: CBOR

Record:
  [u32 length]
  [u8 record_type]    -- node | edge | meta
  [CBOR payload]
```

## Visualization

IM OLD GREG renders as a field, not a node-graph.

Wojaks are densities, not circles. Relationships are gradients and curvature, not lines. The space between seeds has properties: tension, curvature, gradient. You move through the field, not look at it.

The hot/warm/cold model is literal: where you stand is bright. Relational distance dims. Move, and the brightness follows.

Recursive zoom: navigate into a wojak and it expands into its own embedded graph. Zoom out and it collapses.

Multi-axis projection: toggle which axes determine spatial position. The field reorganizes.

## Tech Stack

| Layer | Technology | Role |
|-------|-----------|------|
| Core logic | Curry | Relational reasoning, narrowing, non-determinism, search |
| Backend | KiCS2 | Compiles Curry to Haskell, then to native binary via GHC |
| Geometry | Haskell libraries | Manifold computation (manifolds, goal-geometry), linear algebra (hmatrix, hTensor), graph operations (algebraic-graphs) |
| Storage | .greg (FCAF) | CBOR-encoded append-only binary with witness mesh |
| Build | GitHub Actions | KiCS2 + GHC compilation, binary published to Releases |
| Distribution | Precompiled binary | Download and run. No toolchain required at runtime. |

## Architecture

```
im-old-greg/
|-- README.md
|-- SKILL.md
|-- CLAUDE.md
|-- AGENTS.md
|-- LICENSE                   (AGPL-3.0)
|-- src/
|   |-- curry/
|   |   |-- ImOldGreg.curry   (main entry + CLI dispatch)
|   |   |-- Cbor.curry        (pure Curry CBOR codec)
|   |   |-- Memo.curry        (memo/pepo/wojak data model)
|   |   |-- Axes.curry        (axis structures + coordinate system)
|   |   |-- Metrics.curry     (11 morphisms + 7 routings + 5 measures + 3 antithets + 2 directions + 1 isness)
|   |   |-- Canonicalize.curry (concrete -> abstract shape extraction)
|   |   |-- Analogy.curry     (analogy engine + triangulation)
|   |   |-- Query.curry       (diffusion querying + hot/warm/cold)
|   |   |-- Storage.curry     (.greg FCAF framing + transport)
|   |   |-- Witness.curry     (witness mesh observations)
|   |   |-- Chores.curry      (chore CRUD + suggestion engine)
|   |   +-- AxisSeeds.curry   (starter axis atlas, 3 tiers)
|   +-- haskell/
|       |-- greg-geom.cabal   (helper executable)
|       |-- Geometry.hs       (curvature + chord measures)
|       |-- LinAlg.hs         (wrapper: hmatrix)
|       |-- GraphOps.hs       (wrapper: algebraic-graphs)
|       +-- FFIBridge.hs      (greg-geom main: transport + kernels)
|-- harness/
|   |-- run.sh                (CLI entry point, owns the file boundary)
|   |-- ingest.sh             (grow wojaks)
|   |-- query.sh              (run queries)
|   |-- relate.sh             (find relationships)
|   |-- analogize.sh          (analogy/triangulation queries)
|   +-- suggest.sh            (recommend chores)
|-- .github/
|   +-- workflows/
|       +-- build.yml         (KiCS2 + GHC build + release)
|-- tests/
|   |-- TestMetrics.curry
|   |-- TestAxes.curry
|   |-- TestStorage.curry
|   |-- TestAnalogy.curry
|   +-- TestQuery.curry
|-- reference/
|   +-- metric_definitions.md
+-- templates/
    |-- memo_template.cbor
    |-- pepo_template.cbor
    |-- wojak_template.cbor
    +-- chore_template.cbor
```

## License

AGPL-3.0
