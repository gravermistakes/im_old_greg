# Seven random wikipedia articles as wojaks

Sampled 2026-07-25 with seven pulls of `Special:Random` on
en.wikipedia. Nothing was filtered, swapped, or retried. Grafted
into a field with `greg seed wikipedia`.

## The seven

| seed | what it is | axes |
|------|-----------|------|
| `the-office-au` | Australian mockumentary sitcom, 2024 | 9 |
| `arab-club-final-2020` | football final settled on penalties | 11 |
| `nesseby-village` | coastal village in Finnmark, three names | 7 |
| `morengo` | comune in the province of Bergamo | 7 |
| `igor-sedasev` | member of the VIII Riigikogu, born 1950 | 5 |
| `miguel-parra-abril` | court painter to Ferdinand VII | 9 |
| `robin-coleman` | actress, strongwoman, rower, bodybuilder | 9 |

Thirty nine axes across the field including isness, so the
31-axis floor is cleared by the sample itself rather than by
padding.

## Axis distribution

Axes were taken, not handed out. A wojak holds a coordinate only
where its article puts it there, so twenty seven of the thirty
eight article-borne axes carry exactly one occupant.

The overlaps that exist are real ones:

| axis | occupants | type | why they share it |
|------|-----------|------|-------------------|
| `record` | all seven | vector | one corpus, one sampling method |
| `jurisdiction` | final, nesseby, morengo | lattice | nested administrative containment |
| `nomination` | nesseby, morengo, coleman | matrix | designators against (in use, official) |
| `temporal-extent` | sedasev, parra, coleman | ray | a lifespan, open or closed |
| `terrain` | nesseby, morengo | manifold | a chart point and an elevation |
| `latitude` | nesseby, morengo | scalar | 70.15 N against 45.53 N |
| `mimesis` | office, parra | scalar | depiction claiming fidelity |
| `broadcast` | office, coleman | vector | terrestrial, stream, live |
| `embodiment` | final, coleman | vector | training, appearance, injury |
| `codification` | final, coleman | scalar | how rule-bound the contest is |
| `legitimation` | sedasev, parra | vector | electoral, hereditary, appointive, commercial |

`record` is the one axis all seven occupy, and only because all
seven were drawn from the same place. Coordinates are article
size in kilobytes against citation count, which is the field
measuring how much record it was given rather than how much
subject exists.

## Coordinate types in use

Every one of the eight types appears except ray-of-rays nesting:
scalar, vector, ray, matrix, tensor, graph, lattice, manifold.
Nothing is flattened. The two-by-two `scoreline` tensor on the
final holds teams against (open play, shootout), which is where
the 4-4 draw and the 4-3 shootout stay distinguishable.

## Lateral connections

Nine links, none of them within a domain. Relation names are
drawn from the locked 29.

| a | b | relation |
|---|---|----------|
| `the-office-au` | `igor-sedasev` | Transcendent |
| `the-office-au` | `miguel-parra-abril` | Homomorphic |
| `the-office-au` | `robin-coleman` | Tangential |
| `the-office-au` | `arab-club-final-2020` | Automorphic |
| `arab-club-final-2020` | `robin-coleman` | Homeomorphic |
| `nesseby-village` | `morengo` | Isomorphic |
| `nesseby-village` | `igor-sedasev` | Collateral |
| `igor-sedasev` | `miguel-parra-abril` | Antipodal |
| `miguel-parra-abril` | `robin-coleman` | Inverse |

The transcendent link is the one worth arguing about. A sitcom
about a branch office and a seat in a national chamber both
instantiate the office as a thing that outlives whoever occupies
it, and neither contains the other, so the relation only exists
from above.

## Assumptions

Three numbers are not literally in the article text:

- `co-occupancy` 101 for `igor-sedasev` is the seat count of the
  Riigikogu, which is what membership of it means.
- `deferral` reads the played date of 21 August 2021 as 2021.64
  against a scheduled 2020.
- `temporal-extent` gives living people an open extent measured
  to 2026.

Everything else is stated in the article or its infobox.
