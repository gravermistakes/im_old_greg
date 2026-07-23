-- Query: diffusion, not traversal.
-- A query enters the rhizome at a seed and propagates as signal
-- through connections. Each step, every charged seed radiates a
-- fraction of its signal to its neighbours; signal accumulates.
-- Relevance is accumulated signal. There is no pathfinding, no
-- visited set, no frontier: cycles feed back naturally and are
-- damped by decay.
module Query
  ( Signal, diffuse, resonanceAt
  , Zone (..), attention, zoneOf
  , relatedness, fieldReport
  ) where

import Data.List ( sortBy, sum )

import Cbor
import Wojak

type Signal = [(Seed, Float)]

decay :: Float
decay = 0.5

-- how strongly a connection carries signal: context may carry a
-- "w" weight; default is full conductance
conductance :: Connection -> Float
conductance c = case cborLookup "w" (cnCtx c) of
  Just (CFloat w) -> w
  Just (CInt n)   -> fromInt n
  _               -> 1.0

-- one diffusion step, mass-conserving: every seed keeps
-- (1 - decay) of its signal and radiates the rest, split over
-- its connections by conductance. Total signal stays 1, so the
-- query source cannot be outshone by its own echo.
step :: Field -> Signal -> Signal
step f sig = foldl addTo [] (retained ++ radiated)
 where
  retained = [ (s, v * (1.0 - decay)) | (s, v) <- sig ]
  radiated = concatMap radiate sig
  radiate (s, v) =
    [ (other, v * decay * share c s)
    | c <- fConns f
    , Just other <- [otherEnd s c] ]
  share c s = conductance c / totalCond s
  totalCond s =
    max 1.0e-9 (sum [ conductance c | c <- fConns f
                                    , touches s c ])
  touches s c = cnA c == s || cnB c == s
  otherEnd s c
    | cnA c == s = Just (cnB c)
    | cnB c == s = Just (cnA c)
    | otherwise  = Nothing

addTo :: Signal -> (Seed, Float) -> Signal
addTo sig (s, v) = case lookup s sig of
  Just v0 -> (s, v0 + v) : [ p | p <- sig, fst p /= s ]
  Nothing -> (s, v) : sig

-- diffuse n steps from a seed; relevance is the mass a seed
-- accumulates across all steps. Strongest resonance first.
diffuse :: Field -> Seed -> Int -> Signal
diffuse f s n =
  sortBy (\a b -> snd a >= snd b) (go n [(s, 1.0)] [])
 where
  go k mass acc
    | k <= 0    = foldl addTo acc mass
    | otherwise = go (k - 1) (step f mass) (foldl addTo acc mass)

resonanceAt :: Field -> Seed -> Seed -> Int -> Float
resonanceAt f from to n =
  case lookup to (diffuse f from n) of
    Just v  -> v
    Nothing -> 0.0

-- hot / warm / cold -------------------------------------------
-- Hot: reached within n steps of diffusion. Warm: within 2n.
-- Cold: seed persists, wakes only when a query reaches it.
-- Eviction is by relational distance, never by age.

data Zone = Hot | Warm | Cold
 deriving (Eq, Show)

attention :: Field -> Seed -> Int -> [(Seed, Zone)]
attention f focus n =
  [ (wjSeed w, zone (wjSeed w)) | w <- fWojaks f ]
 where
  near  = map fst (diffuse f focus n)
  wider = map fst (diffuse f focus (2 * n))
  zone s
    | s `elem` near  = Hot
    | s `elem` wider = Warm
    | otherwise      = Cold

zoneOf :: Field -> Seed -> Int -> Seed -> Zone
zoneOf f focus n s =
  case lookup s (attention f focus n) of
    Just z  -> z
    Nothing -> Cold

-- combined relational pull between two seeds: resonance through
-- the rhizome plus proximity in coordinate space on shared axes
relatedness :: Field -> Seed -> Seed -> Float
relatedness f a b =
  resonanceAt f a b steps + proximity
 where
  steps = 4
  proximity = case (wojakBySeed f a, wojakBySeed f b) of
    (Just wa, Just wb) ->
      let shared = [ (ca, cb)
                   | (ax, ca) <- wjCoords wa
                   , Just cb <- [getCoord wb ax] ]
      in if null shared
           then 0.0
           else 1.0 / (1.0 + meanF [ coordDist ca cb
                                   | (ca, cb) <- shared ])
    _ -> 0.0

meanF :: [Float] -> Float
meanF xs = if null xs then 0.0 else sum xs / fromInt (length xs)

-- a phone-width summary of what the field looks like from a seed
fieldReport :: Field -> Seed -> Int -> String
fieldReport f focus n = unlines
  ( ("field: " ++ show (length (fWojaks f)) ++ " wojaks, "
     ++ show (length (fConns f)) ++ " connections, "
     ++ show (fieldDims f) ++ " axes")
  : ("focus: " ++ seedText focus)
  : [ "  " ++ pad (seedText s) ++ " " ++ show z ++ " "
      ++ show (resonanceAt f focus s n)
    | (s, z) <- attention f focus n, s /= focus ] )
 where
  pad t = take 18 (t ++ repeat ' ')
