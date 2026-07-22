-- LinAlg: hmatrix wrappers. All linear algebra the Curry core
-- needs but must not hand-roll lives behind these functions.
module LinAlg
  ( frobenius
  , spectrum
  , principalAxis
  ) where

import Data.List ( sortBy )
import Data.Ord ( comparing, Down (..) )
import Numeric.LinearAlgebra

-- Frobenius distance between two matrices given row-major lists
frobenius :: Int -> Int -> [Double] -> [Double] -> Double
frobenius r c xs ys = norm_Frob (a - b)
 where
  a = (r >< c) xs
  b = (r >< c) ys

-- eigenvalue magnitudes of a square matrix, descending;
-- the shape signature of a graph or operator
spectrum :: Int -> [Double] -> [Double]
spectrum n xs =
  sortBy (comparing Down) (toList (cmap magnitude (eigenvalues m)))
 where
  m = (n >< n) xs

-- dominant direction of a point cloud (rows = points)
principalAxis :: Int -> Int -> [Double] -> [Double]
principalAxis r c xs = toList (head (toColumns v))
 where
  m       = (r >< c) xs
  (_, _, v) = svd m
