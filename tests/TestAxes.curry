-- TestAxes: typed coordinates, recursive nesting, type-aware
-- distance. Coordinates are never flattened to scalars.
module TestAxes where

import Wojak

check :: String -> Bool -> IO ()
check name ok =
  if ok then putStrLn ("ok " ++ name)
        else error ("FAIL " ++ name)

near :: Float -> Float -> Bool
near a b = abs (a - b) < 1.0e-6

main :: IO ()
main = do
  check "scalar distance"
    (near (coordDist (Scalar 1.0) (Scalar 4.0)) 3.0)
  check "vector distance is euclidean"
    (near (coordDist (Vector [Scalar 0.0, Scalar 0.0])
                     (Vector [Scalar 3.0, Scalar 4.0])) 5.0)
  check "distance is symmetric"
    (near (coordDist nested nested2) (coordDist nested2 nested))
  check "identical coords are distance zero"
    (near (coordDist nested nested) 0.0)
  check "cross-type comparison is finite and positive"
    (coordDist (Scalar 1.0) (Vector [Scalar 1.0, Scalar 1.0]) > 0.0)
  check "nesting depth counts layers"
    (coordDepth nested == 3)
  check "dims counts scalar degrees of freedom"
    (coordDims (Vector [Scalar 1.0, Vector [Scalar 2.0, Scalar 3.0]])
       == 3)
  check "tensor keeps its shape"
    (coordType (Tensor [2, 2] (map Scalar [1.0, 2.0, 3.0, 4.0]))
       == TTensor)
  check "graph distance sees edge weight difference"
    (coordDist g1 g2 > 0.0)
  check "minimum field dimensionality is 31"
    (minFieldDims == 31)
 where
  nested = Vector [ Scalar 1.0
                  , Vector [ Scalar 2.0
                           , Vector [Scalar 3.0] ] ]
  nested2 = Vector [ Scalar 1.5
                   , Vector [ Scalar 2.0
                            , Vector [Scalar 2.5] ] ]
  g1 = Graph [Scalar 1.0, Scalar 2.0] [(0, 1, Scalar 1.0)]
  g2 = Graph [Scalar 1.0, Scalar 2.0] [(0, 1, Scalar 3.0)]
