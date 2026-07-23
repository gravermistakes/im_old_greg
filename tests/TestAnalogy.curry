-- TestAnalogy: A : B :: C : ? and triangulation across domains.
-- The dolphin/shark convergence, in miniature.
module TestAnalogy where

import Cbor
import Wojak
import Canonicalize
import Analogy

check :: String -> Bool -> IO ()
check name ok =
  if ok then putStrLn ("ok " ++ name)
        else error ("FAIL " ++ name)

-- two domains, one shape: predator-prey in sea and sky
mkField :: Field
mkField = foldr add emptyField
  [ ("dolphin", 3.0, 0.9)   -- trophic level, streamlining
  , ("sardine", 2.0, 0.7)
  , ("hawk",    3.0, 0.8)
  , ("sparrow", 2.0, 0.6)
  , ("granite", 0.0, 0.1)   -- inert bystander
  ]
 where
  add (n, t, s) f = addWojak
    (Wojak (CText n)
      [ ("trophic-level", Scalar t)
      , ("streamlining", Scalar s) ] []) f

main :: IO ()
main = do
  let f = mkField
  check "dolphin : sardine :: hawk : sparrow"
    (case analogy f (CText "dolphin") (CText "sardine")
                    (CText "hawk") of
       ((s, _) : _) -> s == CText "sparrow"
       []           -> False)

  -- triangulate the predator shape from both domains
  let pat = triangulate f [CText "dolphin", CText "hawk"]
  check "invariant keeps the shared trophic level"
    (lookup "trophic-level" pat == Just (SScalar 3.0))
  check "divergent streamlining opens a hole"
    (lookup "streamlining" pat == Just Hole)
  check "anti-unification: agreement survives"
    (antiUnify (SScalar 1.0) (SScalar 1.0) == SScalar 1.0)
  check "anti-unification: difference becomes a hole"
    (antiUnify (SScalar 1.0) (SScalar 2.0) == Hole)
  check "holes match anything"
    (matchShape Hole (Tensor [2] [Scalar 1.0, Scalar 2.0]))
  check "invariant of instances matches all instances"
    (all (matchShape (invariant [v1, v2])) [v1, v2])
  putStrLn "TestAnalogy: all passed"
 where
  v1 = Vector [Scalar 1.0, Scalar 5.0]
  v2 = Vector [Scalar 1.0, Scalar 9.0]
