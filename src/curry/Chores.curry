-- Chores: field maintenance work, suggested by the field itself.
-- A chore is not a task list imposed from outside; it is what
-- the rhizome reports when asked where it is thin, tangled,
-- or under-witnessed. CRUD plus a suggestion engine.
module Chores
  ( Chore (..), choreToCbor, choreFromCbor
  , suggestChores, renderChores
  ) where

import Cbor
import Axes
import Memo
import Witness

data Chore = Chore
  { chName :: String
  , chWhy  :: String
  , chDone :: Bool
  }
 deriving (Eq, Show)

choreToCbor :: Chore -> CborValue
choreToCbor c = cmap
  [ ("chore", CText (chName c))
  , ("why", CText (chWhy c))
  , ("done", CBool (chDone c)) ]

choreFromCbor :: CborValue -> Maybe Chore
choreFromCbor v =
  case (cborLookup "chore" v, cborLookup "why" v) of
    (Just (CText n), Just (CText w)) ->
      Just (Chore n w (cborLookup "done" v == Just (CBool True)))
    _ -> Nothing

-- the suggestion engine reads the field's structural health
suggestChores :: Field -> [Observation] -> [Chore]
suggestChores f obs = concat
  [ dimChore, orphanChores, flatChores, witnessChore ]
 where
  dimChore
    | dimDeficit f > 0 =
        [ Chore "widen the field"
            (show (fieldDims f) ++ " axes; the field is degenerate "
             ++ "below " ++ show minFieldDims ++ ". Add "
             ++ show (dimDeficit f) ++ " more.") False ]
    | otherwise = []
  orphanChores =
    [ Chore ("connect " ++ seedText (wjSeed w))
        "only touches isness; no lateral connections yet" False
    | w <- fWojaks f
    , wjSeed w /= motherSeed
    , lateralDegree (wjSeed w) == 0 ]
  lateralDegree s =
    length [ c | c <- fConns f
               , (cnA c == s && cnB c /= motherSeed)
                 || (cnB c == s && cnA c /= motherSeed) ]
  flatChores =
    [ Chore ("deepen " ++ seedText (wjSeed w))
        "every coordinate is a bare scalar; type the structure"
        False
    | w <- fWojaks f
    , wjSeed w /= motherSeed
    , not (null (wjCoords w))
    , all (isScalar . snd) (wjCoords w) ]
  isScalar c = case c of
    Scalar _ -> True
    _        -> False
  witnessChore
    | null obs && not (null (fWojaks f)) =
        [ Chore "witness the field"
            "no observations recorded; the mesh is empty" False ]
    | length (unwitnessed obs) > 3 =
        [ Chore "cross-reference observations"
            (show (length (unwitnessed obs))
             ++ " observations stand unreferenced") False ]
    | otherwise = []

renderChores :: [Chore] -> String
renderChores cs
  | null cs   = "field is healthy. no chores.\n"
  | otherwise = unlines
      [ mark c ++ " " ++ chName c ++ "\n    " ++ chWhy c
      | c <- cs ]
 where
  mark c = if chDone c then "[x]" else "[ ]"
