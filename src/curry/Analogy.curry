-- Analogy: A is to B as C is to ?
-- The transformation between A and B is read off their shared
-- axes: morphism verdicts plus per-axis coordinate deltas. That
-- transformation is projected from C over the whole field, and
-- candidates are ranked by how faithfully the A->B relation
-- recurs as C->D.
--
-- Triangulation: given N instances of a shape, anti-unify to the
-- invariant and search the field for everything matching it,
-- regardless of domain. Shared axes are the bridge.
module Analogy
  ( Delta, transformation, analogy, triangulate
  , shapeInstances
  ) where

import Data.List ( sortBy, nub, sum )

import Cbor
import Wojak
import Metrics
import Canonicalize

-- Per-axis evidence preserves structure, distance, and scalar
-- orientation. A signed scalar delta is available only when both
-- coordinates are scalar; nested types retain their native metric.
type Delta = [(String, [(Morphism, Verdict)], Float, Maybe Float)]

transformation :: Field -> Seed -> Seed -> Delta
transformation f a b =
  case (wojakBySeed f a, wojakBySeed f b) of
    (Just wa, Just wb) ->
      [ (ax, morphisms ca cb, coordDist ca cb,
         signedScalarDelta ca cb)
      | (ax, ca) <- wjCoords wa
      , Just cb <- [getCoord wb ax] ]
    _ -> []

signedScalarDelta :: Coord -> Coord -> Maybe Float
signedScalarDelta (Scalar x) (Scalar y) = Just (y - x)
signedScalarDelta _ _ = Nothing

-- Compare shared axes in the same direction, and count names
-- absent from either side. Equal axis counts do not imply
-- equal axis evidence.
deltaDist :: Delta -> Delta -> Float
deltaDist d1 d2 =
  fromInt missing + sum (map axisGap shared)
 where
  shared = [ (v1, g1, s1, v2, g2, s2)
           | (ax1, v1, g1, s1) <- d1
           , (ax2, v2, g2, s2) <- d2
           , ax1 == ax2 ]
  missing =
    length [ ax | (ax, _, _, _) <- d1, not (hasAxis ax d2) ]
    + length [ ax | (ax, _, _, _) <- d2, not (hasAxis ax d1) ]
  hasAxis ax ds = any (\(name, _, _, _) -> name == ax) ds
  axisGap (v1, g1, s1, v2, g2, s2) =
    fromInt (verdictGap v1 v2) + motionGap g1 s1 g2 s2
  motionGap _ (Just x) _ (Just y) = abs (x - y)
  motionGap g1 _ g2 _ = abs (g1 - g2)
  verdictGap v1 v2 =
    length [ m | (m, x) <- v1
               , lookup m v2 /= Nothing
               , lookup m v2 /= Just x ]

-- A : B :: C : ?  ranked candidates with their mismatch score
analogy :: Field -> Seed -> Seed -> Seed -> [(Seed, Float)]
analogy f a b c =
  sortBy (\x y -> snd x <= snd y)
    [ (wjSeed w, deltaDist ab (transformation f c (wjSeed w)))
    | w <- fWojaks f
    , wjSeed w /= c, wjSeed w /= a, wjSeed w /= b
    , wjSeed w /= motherSeed ]
 where
  ab = transformation f a b

-- triangulation ------------------------------------------------

-- Given known instances, extract the invariant per shared axis,
-- then find every other wojak inhabiting those invariants.
triangulate :: Field -> [Seed] -> [(String, Shape)]
triangulate f seeds =
  [ (ax, invariant cs)
  | ax <- sharedAxes
  , let cs = [ c | w <- known, Just c <- [getCoord w ax] ] ]
 where
  known = [ w | s <- seeds, Just w <- [wojakBySeed f s] ]
  sharedAxes = case map (map fst . wjCoords) known of
    []         -> []
    (a0 : as0) -> nub (foldl inter a0 as0)
  inter xs ys = [ x | x <- xs, x `elem` ys ]

-- everything in the field matching an extracted shape,
-- excluding the instances it came from
shapeInstances :: Field -> [(String, Shape)] -> [Seed] -> [Seed]
shapeInstances f pattern exclude =
  [ wjSeed w
  | w <- fWojaks f
  , wjSeed w `notElem` exclude
  , wjSeed w /= motherSeed
  , not (null pattern)
  , all (fits w) pattern ]
 where
  fits w (ax, shape) = case getCoord w ax of
    Just c  -> matchShape shape c
    Nothing -> False
