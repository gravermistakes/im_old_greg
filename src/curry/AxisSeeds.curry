-- AxisSeeds: the starter atlas of axes, mined from Wikipedia's
-- ontology pages and differentiated outward from isness.
--
-- Tier 0: the atoms. Irreducible aspects anything that exists can
--         have. Each applies to a dolphin, a poem, a protocol,
--         and a storm alike.
-- Tier 1: one differentiation step out from an atom.
-- Tier 2: one further step, still domain-agnostic.
--
-- Axes belong to no memo and are owned by nothing. This module
-- does not create axes: it offers seeds. An axis only exists in
-- a field once a wojak takes a coordinate on it. `seed-axes`
-- materializes each entry as a wojak (an axis is itself a bundle
-- of ideas, so it may live in the field like anything else),
-- with its tier as a coordinate on the differentiation axis.
module AxisSeeds
  ( AxisSeed (..)
  , tier0, tier1, tier2, allSeeds
  , seedField, atlasReport
  ) where

import Axes
import Cbor
import Memo

data AxisSeed = AxisSeed
  { asName   :: String
  , asTier   :: Int
  , asParent :: String       -- "" for tier 0
  , asType   :: CoordType
  , asDef    :: String
  }
 deriving (Eq, Show)

allSeeds :: [AxisSeed]
allSeeds = tier0 ++ tier1 ++ tier2

-- tier 0: the atoms --------------------------------------------

tier0 :: [AxisSeed]
tier0 =
  [ atom "extension" TScalar
      "how far a thing spreads through its containing space"
  , atom "duration" TScalar
      "how long a thing persists through time"
  , atom "magnitude" TScalar
      "quantitative measure or size of a thing"
  , atom "multiplicity" TScalar
      "number of distinct parts or instances within a thing"
  , atom "boundary" TGraph
      "distinction between entity and non-entity"
  , atom "position" TVector
      "location relative to a reference context or frame"
  , atom "connectivity" TScalar
      "degree of linkage or relation to other entities"
  , atom "persistence" TScalar
      "continuity of identity through time"
  , atom "polarity" TScalar
      "binary opposition or complementary duality within a thing"
  , atom "state" TScalar
      "current configuration or mode of being"
  , atom "change-rate" TScalar
      "speed at which a thing transforms or becomes otherwise"
  , atom "intensity" TScalar
      "concentration or strength of presence or effect"
  ]
 where
  atom n t d = AxisSeed n 0 "" t d

-- tier 1: one step out ------------------------------------------

tier1 :: [AxisSeed]
tier1 =
  [ ax "reach-uniformity" "extension" TScalar
      "whether extension is evenly distributed or clustered"
  , ax "penetration-degree" "extension" TScalar
      "how much crosses a thing's boundary per unit pressure"
  , ax "directional-consistency" "extension" TScalar
      "uniformity of extent across directions"
  , ax "span" "duration" TScalar
      "absolute temporal length from inception to terminus"
  , ax "periodicity" "duration" TScalar
      "frequency or regularity of recurrence through time"
  , ax "episodicity" "duration" TScalar
      "degree of continuous versus punctuated existence"
  , ax "scale" "magnitude" TScalar
      "absolute size independent of containing context"
  , ax "proportion" "magnitude" TScalar
      "ratio of thing to its immediately containing context"
  , ax "granularity" "magnitude" TScalar
      "fineness or coarseness of measurable subdivision"
  , ax "cardinality" "multiplicity" TScalar
      "exact count of distinct elements in an ensemble"
  , ax "heterogeneity" "multiplicity" TScalar
      "diversity of types or kinds among components"
  , ax "redundancy" "multiplicity" TScalar
      "degree of duplication or repetition within the ensemble"
  , ax "closure-degree" "boundary" TScalar
      "completeness of separation from external non-entity"
  , ax "edge-sharpness" "boundary" TScalar
      "crispness versus gradation of the boundary"
  , ax "topology-genus" "boundary" TGraph
      "structural features of boundary such as holes or handles"
  , ax "centrality" "position" TScalar
      "distance from the boundary of the containing context"
  , ax "embedding-depth" "position" TLattice
      "number of nested contexts that contain the entity"
  , ax "offset-magnitude" "position" TScalar
      "absolute distance from a reference origin or locus"
  , ax "degree" "connectivity" TScalar
      "count of connections to other entities"
  , ax "clustering-coefficient" "connectivity" TScalar
      "tendency to form local groups rather than spread uniformly"
  , ax "path-efficiency" "connectivity" TScalar
      "average distance to other entities through the network"
  , ax "identity-consistency" "persistence" TScalar
      "degree of sameness of core properties across time"
  , ax "structural-stability" "persistence" TScalar
      "resistance to decomposition or disruption"
  , ax "component-renewal" "persistence" TScalar
      "rate at which constituent parts are replaced"
  , ax "opposition-magnitude" "polarity" TScalar
      "strength of contrast between opposing aspects"
  , ax "balance-ratio" "polarity" TScalar
      "relative degree of each opposing aspect"
  , ax "current-state" "polarity" TScalar
      "which pole is presently manifest or dominant"
  , ax "stability-duration" "state" TScalar
      "average length of time the current state persists"
  , ax "transition-barrier" "state" TScalar
      "resistance or energy required to change state"
  , ax "reversibility" "state" TScalar
      "ability to return from current state to prior states"
  , ax "velocity" "change-rate" TScalar
      "quantitative speed of transformation through time"
  , ax "acceleration" "change-rate" TScalar
      "rate of change of velocity itself"
  , ax "rhythm" "change-rate" TScalar
      "periodicity or predictability of the change pattern"
  , ax "concentration-density" "intensity" TScalar
      "strength per unit of spatial measurement"
  , ax "saturation-ratio" "intensity" TScalar
      "current intensity as ratio of maximum possible"
  , ax "gradient-steepness" "intensity" TScalar
      "rate of intensity change across distance"
  ]
 where
  ax n p t d = AxisSeed n 1 p t d

-- tier 2: the second differentiation ----------------------------

tier2 :: [AxisSeed]
tier2 =
  [ ax "radial-saturation" "reach-uniformity" TScalar
      "uniformity of distribution in all radial directions"
  , ax "reach-gradient" "reach-uniformity" TScalar
      "steepness of property decay across distance"
  , ax "penetration-depth" "penetration-degree" TScalar
      "maximum distance a crossing property travels inward"
  , ax "penetration-branching" "penetration-degree" TGraph
      "branching pattern formed as penetration spreads"
  , ax "directional-stability" "directional-consistency" TVector
      "persistence of direction across successive transitions"
  , ax "directional-alignment" "directional-consistency" TVector
      "angular variance relative to a reference direction"
  , ax "scale-hierarchy" "scale" TLattice
      "nesting relationship between discrete scale levels"
  , ax "scale-smoothness" "scale" TScalar
      "continuity of transitions across scale boundaries"
  , ax "ratio-evenness" "proportion" TScalar
      "entropy of the proportional distribution"
  , ax "proportion-variance" "proportion" TScalar
      "spread of proportional relationships around their mean"
  , ax "grain-uniformity" "granularity" TScalar
      "evenness of the distribution of grain sizes"
  , ax "grain-clustering" "granularity" TScalar
      "degree to which similar-sized grains aggregate"
  , ax "cardinality-diversity" "cardinality" TScalar
      "number of distinct types within counted elements"
  , ax "cardinality-concentration" "cardinality" TScalar
      "inequality of the count distribution"
  , ax "heterogeneity-patterning" "heterogeneity" TLattice
      "organization pattern of heterogeneous element types"
  , ax "heterogeneity-contrast" "heterogeneity" TScalar
      "maximum dissimilarity between any two elements"
  , ax "redundancy-distribution" "redundancy" TScalar
      "evenness of the placement of redundant copies"
  , ax "redundancy-tolerance" "redundancy" TScalar
      "minimum redundancy required for continuity"
  , ax "closure-permeability" "closure-degree" TScalar
      "fraction of boundary allowing passage"
  , ax "closure-compactness" "closure-degree" TScalar
      "efficiency of boundary in enclosing interior"
  , ax "edge-discontinuity" "edge-sharpness" TScalar
      "magnitude of property jump at the boundary"
  , ax "edge-width" "edge-sharpness" TScalar
      "thickness of the interior-to-exterior transition zone"
  , ax "genus-nesting" "topology-genus" TGraph
      "hierarchy of how holes relate structurally"
  , ax "genus-singularity" "topology-genus" TScalar
      "count and kind of singular points and defects"
  , ax "centrality-dominance" "centrality" TScalar
      "control exercised through a center over flows"
  , ax "centrality-decay" "centrality" TScalar
      "rate at which influence attenuates from the center"
  , ax "embedding-layers" "embedding-depth" TScalar
      "count of containment boundaries around the entity"
  , ax "embedding-tangency" "embedding-depth" TScalar
      "degree of contact with the containing boundary"
  , ax "offset-direction-variance" "offset-magnitude" TVector
      "angular spread of offsets across elements"
  , ax "offset-coherence" "offset-magnitude" TScalar
      "alignment of offsets with the dominant direction"
  , ax "degree-imbalance" "degree" TScalar
      "inequality of the connection-count distribution"
  , ax "degree-stratification" "degree" TScalar
      "number of discrete connection-count levels"
  , ax "clustering-anisotropy" "clustering-coefficient" TVector
      "directional variance in local clustering"
  , ax "clustering-correlation" "clustering-coefficient" TScalar
      "co-variation of linkage count and local clustering"
  , ax "path-flexibility" "path-efficiency" TScalar
      "count of alternative minimal paths between endpoints"
  , ax "path-convergence" "path-efficiency" TScalar
      "fraction of links shared by many shortest paths"
  , ax "onset-latency" "span" TScalar
      "interval before effects become observable"
  , ax "tail-persistence" "span" TScalar
      "duration of residual effects after the primary ends"
  , ax "cycle-stability" "periodicity" TScalar
      "consistency of period length across repetitions"
  , ax "phase-coherence" "periodicity" TScalar
      "synchronization of cycles with an external reference"
  , ax "inter-episode-interval" "episodicity" TScalar
      "characteristic gap between successive occurrences"
  , ax "episode-clustering" "episodicity" TScalar
      "tendency of occurrences to aggregate in time"
  , ax "continuity-threshold" "identity-consistency" TScalar
      "change permitted before identity is deemed lost"
  , ax "distinguishability-margin" "identity-consistency" TScalar
      "divergence two instances bear while staying equivalent"
  , ax "perturbation-resilience" "structural-stability" TVector
      "capacity to absorb deviation without failure"
  , ax "recovery-rate" "structural-stability" TScalar
      "speed of return to baseline after perturbation"
  , ax "replacement-coordination" "component-renewal" TScalar
      "synchrony of renewal events across the whole"
  , ax "degradation-distribution" "component-renewal" TGraph
      "pattern governing when components fail or renew"
  , ax "tension-intensity" "opposition-magnitude" TScalar
      "force of opposition between the poles"
  , ax "opposition-asymmetry" "opposition-magnitude" TScalar
      "difference in strength between opposing poles"
  , ax "equilibrium-precision" "balance-ratio" TScalar
      "exactness of the balance point between forces"
  , ax "deviation-tolerance" "balance-ratio" TVector
      "range beyond which rebalancing triggers"
  , ax "state-persistence" "current-state" TScalar
      "resistance to leaving the current pole or mode"
  , ax "switching-threshold" "current-state" TScalar
      "condition that triggers transition between poles"
  , ax "metastability-depth" "stability-duration" TScalar
      "cost of leaving a kinetically stable state"
  , ax "escape-probability" "stability-duration" TScalar
      "likelihood of spontaneous transition away"
  , ax "activation-abruptness" "transition-barrier" TScalar
      "sharpness of transition onset past the threshold"
  , ax "transition-hysteresis" "transition-barrier" TScalar
      "path-dependence between forward and reverse change"
  , ax "back-transition-cost" "reversibility" TScalar
      "investment required to reverse a completed change"
  , ax "information-preservation" "reversibility" TScalar
      "reconstructability of prior state from current state"
  , ax "velocity-profile" "velocity" TVector
      "curve of speed variation through the change"
  , ax "peak-speed" "velocity" TScalar
      "maximum instantaneous rate during transition"
  , ax "jerk-magnitude" "acceleration" TScalar
      "rate at which acceleration itself changes"
  , ax "acceleration-consistency" "acceleration" TScalar
      "smoothness of acceleration through a process"
  , ax "harmonic-structure" "rhythm" TTensor
      "frequency content and amplitudes within the rhythm"
  , ax "phase-locking" "rhythm" TScalar
      "synchronization of internal rhythm to external drive"
  , ax "concentration-maximum" "concentration-density" TScalar
      "highest local density anywhere in the whole"
  , ax "distribution-skewness" "concentration-density" TVector
      "asymmetry in the spread of concentration"
  , ax "saturation-threshold" "saturation-ratio" TScalar
      "point at which capacity is reached"
  , ax "overflow-responsiveness" "saturation-ratio" TScalar
      "behavior when saturation capacity is exceeded"
  , ax "gradient-uniformity" "gradient-steepness" TScalar
      "consistency of the rate of change across regions"
  , ax "discontinuity-sharpness" "gradient-steepness" TScalar
      "abruptness of intensity jumps at region boundaries"
  ]
 where
  ax n p t d = AxisSeed n 2 p t d

-- materialization -----------------------------------------------

-- An axis seed becomes a wojak: seed = its name, coordinates on
-- "isness" and "differentiation" (its tier), definition accreted
-- as state. Parent linkage is a lateral connection, not
-- ownership: the rhizome stays flat.
seedField :: Field -> Field
seedField f0 = foldl place f0 allSeeds
 where
  place f s = linkParent s (addWojak (toWojak s) f)
  toWojak s = Wojak
    { wjSeed   = CText (asName s)
    , wjCoords = [ ("differentiation", Scalar (fromInt (asTier s))) ]
    , wjState  = [ ("definition", CText (asDef s))
                 , ("coordinate-type", CText (show (asType s)))
                 , ("kind", CText "axis") ]
    }
  linkParent s f
    | null (asParent s) = f
    | otherwise = connect (CText (asName s)) (CText (asParent s))
                    (cmap [ ("relation", CText "differentiation")
                          , ("w", CFloat 1.0) ]) f

atlasReport :: String
atlasReport = unlines
  ( ("axis atlas: " ++ show (length allSeeds) ++ " seeds ("
     ++ show (length tier0) ++ " atoms, "
     ++ show (length tier1) ++ " tier-1, "
     ++ show (length tier2) ++ " tier-2)")
  : [ pad (asName s) ++ " t" ++ show (asTier s)
      ++ " " ++ pad2 (show (asType s))
      ++ " " ++ asDef s
    | s <- allSeeds ] )
 where
  pad t  = take 26 (t ++ repeat ' ')
  pad2 t = take 9 (t ++ repeat ' ')
