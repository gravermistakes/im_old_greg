-- Metrics: the 29 relationship types. LOCKED.
-- 11 morphisms + 7 routings + 5 measures + 3 antithets
-- + 2 directions + 1 isness = 29.
-- Do not add, remove, rename, merge, or redefine without
-- explicit operator instruction.
--
-- Morphism detection here is structural and conservative: a
-- morphism is reported only when the evidence in the coordinates
-- supports it. The three differential morphisms (diffeomorphic,
-- symplectic, holomorphic) need smooth structure that only the
-- geometry helper can certify; Curry reports them as candidates,
-- never as confirmed.
module Metrics
  ( Relation (..), Morphism (..), Routing (..), Measure (..)
  , Antithet (..), Direction (..)
  , allRelations, relationName, relationCount
  , Verdict (..), morphisms, morphismVerdict
  , shapeSkeleton, sameSkeleton
  ) where

import Data.List ( sortBy, sum )

import Wojak

data Morphism
  = Isomorphic | Isometric | Homomorphic | Homeomorphic
  | Diffeomorphic | Symplectic | Holomorphic | Automorphic
  | Endomorphic | Homothetic | Anisometric
 deriving (Eq, Show)

data Routing
  = Lineal | Siblial | Collateral | Tangential
  | Convergent | Divergent | Orthogonal
 deriving (Eq, Show)

data Measure
  = Geodesic | Density | Curvature | Resonance | Depth
 deriving (Eq, Show)

data Antithet
  = Inverse | Complement | Antipodal
 deriving (Eq, Show)

data Direction
  = Immanent | Transcendent
 deriving (Eq, Show)

data Relation
  = RMorphism Morphism
  | RRouting  Routing
  | RMeasure  Measure
  | RAntithet Antithet
  | RDirection Direction
  | RIsness
 deriving (Eq, Show)

allRelations :: [Relation]
allRelations =
  map RMorphism [ Isomorphic, Isometric, Homomorphic, Homeomorphic
                , Diffeomorphic, Symplectic, Holomorphic, Automorphic
                , Endomorphic, Homothetic, Anisometric ]
  ++ map RRouting [ Lineal, Siblial, Collateral, Tangential
                  , Convergent, Divergent, Orthogonal ]
  ++ map RMeasure [ Geodesic, Density, Curvature, Resonance, Depth ]
  ++ map RAntithet [ Inverse, Complement, Antipodal ]
  ++ map RDirection [ Immanent, Transcendent ]
  ++ [ RIsness ]

relationCount :: Int
relationCount = length allRelations   -- always 29

relationName :: Relation -> String
relationName r = case r of
  RMorphism m  -> show m
  RRouting  x  -> show x
  RMeasure  m  -> show m
  RAntithet a  -> show a
  RDirection d -> show d
  RIsness      -> "Isness"

-- verdicts ----------------------------------------------------

data Verdict = Confirmed | Candidate | Absent
 deriving (Eq, Show)

-- every morphism gets a verdict against a coordinate pair
morphisms :: Coord -> Coord -> [(Morphism, Verdict)]
morphisms a b =
  [ (m, morphismVerdict m a b)
  | m <- [ Isomorphic, Isometric, Homomorphic, Homeomorphic
         , Diffeomorphic, Symplectic, Holomorphic, Automorphic
         , Endomorphic, Homothetic, Anisometric ] ]

morphismVerdict :: Morphism -> Coord -> Coord -> Verdict
morphismVerdict m a b = case m of
  Isomorphic   -> confirmedIf (sameSkeleton a b
                               && sameMultiset (leafList a) (leafList b))
  Isometric    -> confirmedIf (sameSkeleton a b
                               && sameGaps (leafList a) (leafList b))
  Homomorphic  -> confirmedIf (skeletonEmbeds a b || skeletonEmbeds b a)
  Homeomorphic -> confirmedIf (sameTopology a b)
  Diffeomorphic -> smoothCandidate a b
  Symplectic    -> smoothCandidate a b
  Holomorphic   -> smoothCandidate a b
  Automorphic  -> confirmedIf (selfSimilar a && selfSimilar b)
  Endomorphic  -> confirmedIf (skeletonEmbeds a a && sameSkeleton a b)
  Homothetic   -> confirmedIf (uniformScale a b)
  Anisometric  -> confirmedIf (sameSkeleton a b
                               && not (uniformScale a b)
                               && not (sameMultiset (leafList a)
                                                    (leafList b)))
 where
  confirmedIf c = if c then Confirmed else Absent

-- smooth morphisms: same skeleton makes a candidate; the
-- geometry helper must confirm differentiability
smoothCandidate :: Coord -> Coord -> Verdict
smoothCandidate a b =
  if sameSkeleton a b then Candidate else Absent

-- structural machinery -----------------------------------------

-- the skeleton: coordinate structure with all scalars erased
data Skeleton
  = KScalar
  | KVector [Skeleton]
  | KRay Skeleton Skeleton
  | KMatrix [[Skeleton]]
  | KTensor [Int] [Skeleton]
  | KGraph Int [(Int, Int)]
  | KLattice Int [(Int, Int)]
  | KManifold Int
 deriving (Eq, Show)

shapeSkeleton :: Coord -> Skeleton
shapeSkeleton c = case c of
  Scalar _      -> KScalar
  Vector xs     -> KVector (map shapeSkeleton xs)
  Ray o d       -> KRay (shapeSkeleton o) (shapeSkeleton d)
  Matrix rows   -> KMatrix (map (map shapeSkeleton) rows)
  Tensor s xs   -> KTensor s (map shapeSkeleton xs)
  Graph ns es   -> KGraph (length ns) [ (i, j) | (i, j, _) <- es ]
  Lattice xs o  -> KLattice (length xs) o
  Manifold pts  -> KManifold (length pts)

sameSkeleton :: Coord -> Coord -> Bool
sameSkeleton a b = shapeSkeleton a == shapeSkeleton b

-- does the skeleton of a embed into the skeleton of b?
skeletonEmbeds :: Coord -> Coord -> Bool
skeletonEmbeds a b =
  embeds (shapeSkeleton a) (shapeSkeleton b)

embeds :: Skeleton -> Skeleton -> Bool
embeds s t = s == t || any (embeds s) (children t)

children :: Skeleton -> [Skeleton]
children s = case s of
  KScalar       -> []
  KVector xs    -> xs
  KRay o d      -> [o, d]
  KMatrix rows  -> concat rows
  KTensor _ xs  -> xs
  KGraph _ _    -> []
  KLattice _ _  -> []
  KManifold _   -> []

-- a shape is self-similar when a strict sub-part repeats the whole
selfSimilar :: Coord -> Bool
selfSimilar c =
  any (embeds sk) (properParts (shapeSkeleton c))
 where
  sk = shapeSkeleton c
  properParts t = concatMap (\x -> x : properParts x) (children t)

-- topology: connectivity ignoring metric stretch
sameTopology :: Coord -> Coord -> Bool
sameTopology a b = topo (shapeSkeleton a) == topo (shapeSkeleton b)
 where
  topo s = case s of
    KGraph n es   -> ("graph", n, length es)
    KLattice n o  -> ("lattice", n, length o)
    KMatrix rows  -> ("grid", length rows, sumLens rows)
    other         -> ("chain", countNodes other, 0)
  sumLens rows = sum (map length rows)
  countNodes t = 1 + sum (map countNodes (children t))

leafList :: Coord -> [Float]
leafList c = case c of
  Scalar x      -> [x]
  Vector xs     -> concatMap leafList xs
  Ray o d       -> leafList o ++ leafList d
  Matrix rows   -> concatMap leafList (concat rows)
  Tensor _ xs   -> concatMap leafList xs
  Graph ns es   -> concatMap leafList ns
                   ++ concat [ leafList w | (_, _, w) <- es ]
  Lattice xs _  -> concatMap leafList xs
  Manifold pts  -> concat [ p ++ leafList v | (p, v) <- pts ]

sameMultiset :: [Float] -> [Float] -> Bool
sameMultiset xs ys =
  length xs == length ys && sortF xs == sortF ys

-- isometry evidence: successive gaps between sorted leaves match
sameGaps :: [Float] -> [Float] -> Bool
sameGaps xs ys =
  length xs == length ys && all small (zipWith (-) (gaps xs) (gaps ys))
 where
  gaps zs = let s = sortF zs in zipWith (-) (drop 1 s) s
  small d = abs d < 1.0e-9

-- homothety: b = k * a for one uniform k
uniformScale :: Coord -> Coord -> Bool
uniformScale a b =
  sameSkeleton a b && case (leafList a, leafList b) of
    (xs, ys) -> length xs == length ys && not (null ks)
                && all (\k -> abs (k - head ks) < 1.0e-9) ks
                && abs (head ks - 1.0) > 1.0e-9
     where
      ks = [ y / x | (x, y) <- zip xs ys, abs x > 1.0e-12 ]

sortF :: [Float] -> [Float]
sortF = sortBy (<=)
