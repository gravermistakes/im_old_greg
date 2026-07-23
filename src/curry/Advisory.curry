-- Advisory: structural self-report from the field.
-- The field says where it is thin, isolated, or under-typed.
-- These are not tasks imposed from outside; they are what the
-- rhizome surfaces when asked where it wants attention.
module Advisory
  ( Advisory (..), advisoryToCbor, advisoryFromCbor
  , fieldAdvisories, renderAdvisories
  ) where

import Cbor
import Wojak

data Advisory = Advisory
  { adName :: String
  , adWhy  :: String
  , adDone :: Bool
  }
 deriving (Eq, Show)

advisoryToCbor :: Advisory -> CborValue
advisoryToCbor a = cmap
  [ ("advisory", CText (adName a))
  , ("why",      CText (adWhy a))
  , ("done",     CBool (adDone a)) ]

advisoryFromCbor :: CborValue -> Maybe Advisory
advisoryFromCbor v =
  case (cborLookup "advisory" v, cborLookup "why" v) of
    (Just (CText n), Just (CText w)) ->
      Just (Advisory n w (cborLookup "done" v == Just (CBool True)))
    _ -> Nothing

fieldAdvisories :: Field -> [Advisory]
fieldAdvisories f = concat
  [ dimAdvisory, orphanAdvisories, flatAdvisories ]
 where
  dimAdvisory
    | dimDeficit f > 0 =
        [ Advisory "widen the field"
            (show (fieldDims f) ++ " axes; the field is degenerate "
             ++ "below " ++ show minFieldDims ++ ". Add "
             ++ show (dimDeficit f) ++ " more.") False ]
    | otherwise = []
  orphanAdvisories =
    [ Advisory ("connect " ++ seedText (wjSeed w))
        "only touches isness; no lateral connections yet" False
    | w <- fWojaks f
    , wjSeed w /= motherSeed
    , lateralDegree (wjSeed w) == 0 ]
  lateralDegree s =
    length [ c | c <- fConns f
               , (cnA c == s && cnB c /= motherSeed)
                 || (cnB c == s && cnA c /= motherSeed) ]
  flatAdvisories =
    [ Advisory ("deepen " ++ seedText (wjSeed w))
        "every coordinate is a bare scalar; type the structure"
        False
    | w <- fWojaks f
    , wjSeed w /= motherSeed
    , not (null (wjCoords w))
    , all (isScalar . snd) (wjCoords w) ]
  isScalar c = case c of
    Scalar _ -> True
    _        -> False

renderAdvisories :: [Advisory] -> String
renderAdvisories as
  | null as   = "field is coherent. no advisories.\n"
  | otherwise = unlines
      [ mark a ++ " " ++ adName a ++ "\n    " ++ adWhy a
      | a <- as ]
 where
  mark a = if adDone a then "[x]" else "[ ]"
