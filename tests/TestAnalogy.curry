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

  -- A signed scalar change is not interchangeable with its reverse.
  let directed = foldr addScalar emptyField
        [ ("base", 1.0), ("target", 3.0)
        , ("query", 10.0), ("reverse", 8.0), ("forward", 12.0) ]
  let rising = analogy directed (CText "base") (CText "target")
                               (CText "query")
  check "rising scalar analogy favors the forward change"
    (case (lookup (CText "forward") rising,
           lookup (CText "reverse") rising) of
       (Just good, Just bad) -> good < bad
       _ -> False)

  let falling = analogy directed (CText "target") (CText "base")
                                (CText "query")
  check "falling scalar analogy favors the reverse change"
    (case (lookup (CText "reverse") falling,
           lookup (CText "forward") falling) of
       (Just good, Just bad) -> good < bad
       _ -> False)

  -- Equal numbers of differently named axes must not appear
  -- equivalent just because the uninformative isness axis matches.
  let disjoint = foldr addWojak emptyField
        [ Wojak (CText "a1") [("axis-a", Scalar 1.0)] []
        , Wojak (CText "a2") [("axis-a", Scalar 3.0)] []
        , Wojak (CText "b1") [("axis-b", Scalar 10.0)] []
        , Wojak (CText "b2") [("axis-b", Scalar 12.0)] [] ]
  let unrelated = analogy disjoint (CText "a1") (CText "a2")
                                   (CText "b1")
  check "disjoint axis evidence cannot score as an exact analogy"
    (case lookup (CText "b2") unrelated of
       Just mismatch -> mismatch > 0.0
       Nothing       -> False)

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
  addScalar (name, value) f = addWojak
    (Wojak (CText name) [("position", Scalar value)] []) f
  v1 = Vector [Scalar 1.0, Scalar 5.0]
  v2 = Vector [Scalar 1.0, Scalar 9.0]
