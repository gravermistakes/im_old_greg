-- TestMetrics: the 29 are locked; morphism verdicts behave.
module TestMetrics where

import Axes
import Metrics

check :: String -> Bool -> IO ()
check name ok =
  if ok then putStrLn ("ok " ++ name)
        else error ("FAIL " ++ name)

main :: IO ()
main = do
  check "exactly 29 relationship types" (relationCount == 29)
  check "11 morphisms"
    (length [ r | r@(RMorphism _) <- allRelations ] == 11)
  check "7 routings"
    (length [ r | r@(RRouting _) <- allRelations ] == 7)
  check "5 measures"
    (length [ r | r@(RMeasure _) <- allRelations ] == 5)
  check "3 antithets"
    (length [ r | r@(RAntithet _) <- allRelations ] == 3)
  check "2 directions"
    (length [ r | r@(RDirection _) <- allRelations ] == 2)
  check "1 isness"
    (length [ r | r@RIsness <- allRelations ] == 1)

  let v2  = Vector [Scalar 1.0, Scalar 2.0]
      v2' = Vector [Scalar 2.0, Scalar 1.0]
      v2s = Vector [Scalar 2.0, Scalar 4.0]
      v2w = Vector [Scalar 1.0, Scalar 5.0]
      v3  = Vector [Scalar 1.0, Scalar 2.0, Scalar 3.0]

  check "isomorphic: same shape, permuted labels"
    (morphismVerdict Isomorphic v2 v2' == Confirmed)
  check "isomorphic: different shape absent"
    (morphismVerdict Isomorphic v2 v3 == Absent)
  check "homothetic: uniform doubling"
    (morphismVerdict Homothetic v2 v2s == Confirmed)
  check "anisometric: uneven scaling"
    (morphismVerdict Anisometric v2 v2w == Confirmed)
  check "isometric: gaps preserved under shift"
    (morphismVerdict Isometric v2
       (Vector [Scalar 11.0, Scalar 12.0]) == Confirmed)
  check "smooth morphisms are candidates, never confirmed"
    (morphismVerdict Diffeomorphic v2 v2' == Candidate
     && morphismVerdict Symplectic v2 v2' == Candidate
     && morphismVerdict Holomorphic v2 v2' == Candidate)
  check "homomorphic: sub-shape embeds"
    (morphismVerdict Homomorphic
       (Vector [Scalar 1.0])
       (Vector [Vector [Scalar 3.0]]) == Confirmed)
  putStrLn "TestMetrics: all passed"
