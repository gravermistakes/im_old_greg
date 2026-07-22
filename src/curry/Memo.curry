-- Memo: the three layers.
-- Wojaks are ground truth: an immutable seed plus mutable accretion.
-- Pepos and memos are descriptive lenses computed over the field.
-- They own nothing, contain nothing, and are never stored as
-- parents of anything. Membership is derived, on demand, from
-- shared axis coordinates. Deleting every pepo and memo loses
-- zero information.
module Memo
  ( Seed, Wojak (..), Connection (..), Field (..)
  , Pepo (..), MemoLens (..)
  , emptyField, motherSeed, isnessWojak
  , addWojak, connect, setCoord, getCoord
  , wojakBySeed, fieldAxes, fieldDims, dimDeficit
  , pepoMembers, memoMembers
  , wojakToCbor, wojakFromCbor
  , connToCbor, connFromCbor
  , seedText
  ) where

import Data.List ( nub )

import Cbor
import Axes

-- The seed IS the identity: an arbitrary CBOR value, not a hash
-- of one. Two wojaks with equal seeds are the same wojak.
type Seed = CborValue

data Wojak = Wojak
  { wjSeed   :: Seed
  , wjCoords :: [(String, Coord)]   -- axis name -> coordinate
  , wjState  :: [(String, CborValue)]  -- accreted context
  }
 deriving (Eq, Show)

-- Direction- and cycle-agnostic: a and b are peers. Whatever
-- directedness means lives inside the CBOR context.
data Connection = Connection
  { cnA   :: Seed
  , cnB   :: Seed
  , cnCtx :: CborValue
  }
 deriving (Eq, Show)

data Field = Field
  { fWojaks :: [Wojak]
  , fConns  :: [Connection]
  }
 deriving (Eq, Show)

-- descriptive layers ------------------------------------------
-- A pepo names a tight region: wojaks within a radius of a focus
-- coordinate on named axes. A memo names a broad region: wojaks
-- that merely have coordinates on a family of axes. Both are
-- queries, not containers.

data Pepo = Pepo
  { ppName   :: String
  , ppAxes   :: [(String, Coord)]   -- focus per axis
  , ppRadius :: Float
  }
 deriving (Eq, Show)

data MemoLens = MemoLens
  { mmName :: String
  , mmAxes :: [String]
  }
 deriving (Eq, Show)

-- isness -------------------------------------------------------

motherSeed :: Seed
motherSeed = CText "isness"

isnessWojak :: Wojak
isnessWojak = Wojak
  { wjSeed   = motherSeed
  , wjCoords = [("isness", Scalar 0.0)]
  , wjState  = []
  }

emptyField :: Field
emptyField = Field [isnessWojak] []

-- growth -------------------------------------------------------

-- Every new seed connects to isness: not as child to parent,
-- but as a thing that exists touching the fact of existence.
addWojak :: Wojak -> Field -> Field
addWojak w f
  | any (\x -> wjSeed x == wjSeed w) (fWojaks f) = f
  | otherwise = f
      { fWojaks = fWojaks f ++ [withIsness]
      , fConns  = fConns f ++ [toIsness]
      }
 where
  withIsness
    | any ((== "isness") . fst) (wjCoords w) = w
    | otherwise = w { wjCoords = ("isness", Scalar 1.0) : wjCoords w }
  toIsness = Connection (wjSeed w) motherSeed
               (cmap [("relation", CText "isness")])

connect :: Seed -> Seed -> CborValue -> Field -> Field
connect a b ctx f = f { fConns = fConns f ++ [Connection a b ctx] }

setCoord :: Seed -> String -> Coord -> Field -> Field
setCoord s ax c f = f { fWojaks = map upd (fWojaks f) }
 where
  upd w
    | wjSeed w == s =
        w { wjCoords = (ax, c) : [ p | p <- wjCoords w, fst p /= ax ] }
    | otherwise = w

getCoord :: Wojak -> String -> Maybe Coord
getCoord w ax = lookup ax (wjCoords w)

wojakBySeed :: Field -> Seed -> Maybe Wojak
wojakBySeed f s = case [ w | w <- fWojaks f, wjSeed w == s ] of
  (w : _) -> Just w
  []      -> Nothing

-- axes emerge from coordinates; nobody declares them
fieldAxes :: Field -> [String]
fieldAxes f = nub (concatMap (map fst . wjCoords) (fWojaks f))

fieldDims :: Field -> Int
fieldDims = length . fieldAxes

dimDeficit :: Field -> Int
dimDeficit f = max 0 (minFieldDims - fieldDims f)

-- derived membership -------------------------------------------

pepoMembers :: Field -> Pepo -> [Wojak]
pepoMembers f p =
  [ w | w <- fWojaks f, inside w ]
 where
  inside w = all near (ppAxes p)
   where
    near (ax, focus) = case getCoord w ax of
      Just c  -> coordDist c focus <= ppRadius p
      Nothing -> False

memoMembers :: Field -> MemoLens -> [Wojak]
memoMembers f m =
  [ w | w <- fWojaks f
      , any (\ax -> getCoord w ax /= Nothing) (mmAxes m) ]

-- CBOR mapping -------------------------------------------------

wojakToCbor :: Wojak -> CborValue
wojakToCbor w = cmap
  [ ("seed", wjSeed w)
  , ("coords", CMap [ (CText ax, coordToCbor c)
                    | (ax, c) <- wjCoords w ])
  , ("state", CMap [ (CText k, v) | (k, v) <- wjState w ])
  ]

wojakFromCbor :: CborValue -> Maybe Wojak
wojakFromCbor v = case ( cborLookup "seed" v
                       , cborLookup "coords" v
                       , cborLookup "state" v ) of
  (Just s, Just (CMap cs), Just (CMap st)) ->
    case mapM coordEntry cs of
      Just coords -> Just (Wojak s coords (map stateEntry st))
      Nothing     -> Nothing
  _ -> Nothing
 where
  coordEntry (k, c) = case k of
    CText ax -> case coordFromCbor c of
      Just c' -> Just (ax, c')
      Nothing -> Nothing
    _ -> Nothing
  stateEntry (k, x) = case k of
    CText t -> (t, x)
    _       -> (show k, x)

connToCbor :: Connection -> CborValue
connToCbor c = cmap
  [ ("a", cnA c), ("b", cnB c), ("ctx", cnCtx c) ]

connFromCbor :: CborValue -> Maybe Connection
connFromCbor v = case ( cborLookup "a" v
                      , cborLookup "b" v
                      , cborLookup "ctx" v ) of
  (Just a, Just b, Just ctx) -> Just (Connection a b ctx)
  _                          -> Nothing

seedText :: Seed -> String
seedText s = case s of
  CText t -> t
  other   -> show other
