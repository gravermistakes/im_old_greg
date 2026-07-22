-- Witness: the witness mesh. Observations reference N other
-- observations. Not a chain: a mesh. Not hashed: referenced by
-- position in the append order. Trust accumulates the way the
-- field does: by density of cross-reference, not by authority.
module Witness
  ( Observation (..)
  , obsToCbor, obsFromCbor
  , encodeMesh, decodeMesh, appendObs
  , corroboration, unwitnessed
  ) where

import Cbor
import Storage

data Observation = Observation
  { obRefs :: [Int]        -- indexes of observations this one saw
  , obBody :: CborValue    -- what was observed
  }
 deriving (Eq, Show)

obsToCbor :: Observation -> CborValue
obsToCbor o = cmap
  [ ("refs", CList (map CInt (obRefs o)))
  , ("body", obBody o) ]

obsFromCbor :: CborValue -> Maybe Observation
obsFromCbor v = case (cborLookup "refs" v, cborLookup "body" v) of
  (Just (CList rs), Just b) ->
    case mapM asInt rs of
      Just refs -> Just (Observation refs b)
      Nothing   -> Nothing
  _ -> Nothing
 where
  asInt x = case x of
    CInt n -> Just n
    _      -> Nothing

encodeMesh :: [Observation] -> [Int]
encodeMesh obs =
  appendRecords [] [ MetaRec (obsToCbor o) | o <- obs ]

decodeMesh :: [Int] -> [Observation]
decodeMesh bs = case bodyBytes bs of
  Just body -> [ o | MetaRec v <- unframe body
                   , Just o <- [obsFromCbor v] ]
  Nothing   -> []

appendObs :: [Int] -> Observation -> [Int]
appendObs existing o = appendRecords existing [MetaRec (obsToCbor o)]

-- how many later observations point back at observation i
corroboration :: [Observation] -> Int -> Int
corroboration obs i =
  length [ o | o <- obs, i `elem` obRefs o ]

-- observations nobody has referenced yet: the growing edge
unwitnessed :: [Observation] -> [Int]
unwitnessed obs =
  [ i | (i, _) <- zip [0 ..] obs, corroboration obs i == 0 ]
