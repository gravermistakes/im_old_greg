-- TestQuery: diffusion, not traversal. Signal spreads, decays,
-- accumulates; attention zones follow relational distance.
module TestQuery where

import Cbor
import Wojak
import Query

check :: String -> Bool -> IO ()
check name ok =
  if ok then putStrLn ("ok " ++ name)
        else error ("FAIL " ++ name)

lateral :: CborValue
lateral = cmap [("relation", CText "lateral")]

mkField :: Field
mkField =
  connect (CText "a") (CText "b") lateral
    (connect (CText "b") (CText "c") lateral
      (foldr addW emptyField ["a", "b", "c", "far"]))
 where
  addW n f = addWojak (Wojak (CText n) [("x", Scalar 1.0)] []) f

main :: IO ()
main = do
  let f = mkField
  check "signal reaches a direct neighbour"
    (resonanceAt f (CText "a") (CText "b") 3 > 0.0)
  check "signal reaches two hops out"
    (resonanceAt f (CText "a") (CText "c") 4 > 0.0)
  check "nearer seeds resonate more strongly"
    (resonanceAt f (CText "a") (CText "b") 4
       > resonanceAt f (CText "a") (CText "c") 4)
  check "diffusion source keeps the strongest signal"
    (case diffuse f (CText "a") 4 of
       ((s, _) : _) -> s == CText "a"
       []           -> False)
  check "hot zone contains direct neighbour"
    (zoneOf f (CText "a") 2 (CText "b") == Hot)
  check "unconnected seed beyond isness stays cooler"
    (zoneOf f (CText "a") 1 (CText "far") /= Hot)
  check "relatedness sees shared axes"
    (relatedness f (CText "a") (CText "far") > 0.0)
  putStrLn "TestQuery: all passed"
