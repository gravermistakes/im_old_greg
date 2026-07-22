-- Geometry: manifold-flavoured measures built on hmatrix
-- primitives. True Riemannian machinery (connections, parallel
-- transport) arrives when the `manifolds` package is wired in;
-- everything here is exact linear algebra, not approximation.
module Geometry
  ( chordLength
  , sampledCurvature
  , triangleExcess
  ) where

import Numeric.LinearAlgebra

-- straight-chord length between two points in the embedding
chordLength :: [Double] -> [Double] -> Double
chordLength xs ys = norm_2 (fromList xs - fromList ys)

-- discrete curvature of a sampled path: how much the polyline
-- turns per unit length (Frenet-style, from exact vectors)
sampledCurvature :: [[Double]] -> Double
sampledCurvature pts
  | length pts < 3 = 0
  | otherwise      = sum turns / max 1 (sum lens)
 where
  vs    = map fromList pts
  segs  = zipWith (-) (tail vs) vs
  lens  = map norm_2 segs
  turns = zipWith angle segs (tail segs)
  angle u v
    | norm_2 u * norm_2 v == 0 = 0
    | otherwise = acos (max (-1) (min 1 (dot u v / (norm_2 u * norm_2 v))))

-- deviation of triangle angle sum from pi: positive means the
-- three points sit in a positively curved region of the field
triangleExcess :: [Double] -> [Double] -> [Double] -> Double
triangleExcess a b c = angleAt a b c + angleAt b a c + angleAt c a b - pi
 where
  angleAt p q r = ang (fromList q - fromList p) (fromList r - fromList p)
  ang u v
    | norm_2 u * norm_2 v == 0 = 0
    | otherwise = acos (max (-1) (min 1 (dot u v / (norm_2 u * norm_2 v))))
