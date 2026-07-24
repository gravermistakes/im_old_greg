-- Storage: the .greg format (Fractal Content-Addressed
-- Continuous Field). Append-only CBOR records. Flat. No indexes,
-- no schemas, no hierarchy: structure emerges from the data.
--
-- This module turns fields into byte lists and back. It never
-- touches the filesystem: the harness moves bytes (as hex on
-- stdin/stdout) via the greg-geom helper, so the on-disk file is
-- byte-exact regardless of locale.
--
--   Header:  "IMOLDGREG" | u8 version | CBOR "CBOR"
--   Record:  u32 length | u8 type | CBOR payload
--   Types:   0 = node, 1 = edge, 2 = meta
module Storage
  ( Record (..)
  , encodeField, decodeField
  , appendRecords, recordsOf, replay
  , compact, unframe, bodyBytes
  , bytesToB64, b64ToBytes
  ) where

import Cbor
import Wojak

data Record
  = NodeRec CborValue     -- wojak (seed + coords + state)
  | EdgeRec CborValue     -- connection (a, b, ctx)
  | MetaRec CborValue     -- anything else; latest-wins by key
 deriving (Eq, Show)

magic :: [Int]
magic = map ord "IMOLDGREG"

version :: Int
version = 1

header :: [Int]
header = magic ++ [version] ++ encode (CText "CBOR")

-- framing ------------------------------------------------------

frame :: Record -> [Int]
frame r = u32 (length payload + 1) ++ [tag] ++ payload
 where
  (tag, payload) = case r of
    NodeRec v -> (0, encode v)
    EdgeRec v -> (1, encode v)
    MetaRec v -> (2, encode v)

u32 :: Int -> [Int]
u32 n =
  [ n `div` 16777216 `mod` 256
  , n `div` 65536 `mod` 256
  , n `div` 256 `mod` 256
  , n `mod` 256 ]

unframe :: [Int] -> [Record]
unframe bs = case bs of
  (l3 : l2 : l1 : l0 : rest) ->
    let len = ((l3 * 256 + l2) * 256 + l1) * 256 + l0
        (body, rest') = splitAt len rest
    in case body of
         (t : pl) -> case decodeFull pl of
           Just v  -> mkRec t v : unframe rest'
           Nothing -> unframe rest'
         []       -> unframe rest'
  _ -> []
 where
  mkRec t v = case t of
    0 -> NodeRec v
    1 -> EdgeRec v
    _ -> MetaRec v

-- whole-field encode/decode ------------------------------------

recordsOf :: Field -> [Record]
recordsOf f =
  [ NodeRec (wojakToCbor w) | w <- fWojaks f ]
  ++ [ EdgeRec (connToCbor c) | c <- fConns f ]

encodeField :: Field -> [Int]
encodeField f = header ++ concatMap frame (recordsOf f)

decodeField :: [Int] -> Maybe Field
decodeField bs = case bodyBytes bs of
  Just body -> Just (replay (unframe body))
  Nothing   -> Nothing

-- strip and validate the header, returning the record stream
bodyBytes :: [Int] -> Maybe [Int]
bodyBytes bs
  | take 9 bs == magic =
      case drop 9 bs of
        (v : rest) | v == version ->
          case decode rest of
            Just (CText "CBOR", body) -> Just body
            _                         -> Nothing
        _ -> Nothing
  | otherwise = Nothing

-- replay records in order onto an empty field. Later node
-- records for a known seed are accretion: coords and state
-- merge, seed never changes. This is what append-only means.
replay :: [Record] -> Field
replay = foldl apply emptyField
 where
  apply f r = case r of
    NodeRec v -> case wojakFromCbor v of
      Just w  -> accrete f w
      Nothing -> f
    EdgeRec v -> case connFromCbor v of
      Just c  -> f { fConns = fConns f ++ [c] }
      Nothing -> f
    MetaRec _ -> f

-- unlike addWojak, replay inserts nodes verbatim: connections
-- (including the isness link) arrive as their own edge records,
-- so decode reproduces exactly what encode saw
accrete :: Field -> Wojak -> Field
accrete f w = case wojakBySeed f (wjSeed w) of
  Nothing -> f { fWojaks = fWojaks f ++ [w] }
  Just old -> f { fWojaks = map upd (fWojaks f) }
   where
    upd x
      | wjSeed x == wjSeed w = merged
      | otherwise            = x
    merged = old
      { wjCoords = wjCoords w
                   ++ [ p | p <- wjCoords old
                          , lookup (fst p) (wjCoords w) == Nothing ]
      , wjState  = wjState w
                   ++ [ p | p <- wjState old
                          , lookup (fst p) (wjState w) == Nothing ]
      }

-- append without rewriting: new records after existing bytes
appendRecords :: [Int] -> [Record] -> [Int]
appendRecords existing rs
  | null existing = header ++ concatMap frame rs
  | otherwise     = existing ++ concatMap frame rs

-- compaction folds accretion into one record per seed; the
-- rhizome stays flat, history collapses, identity survives
compact :: [Int] -> Maybe [Int]
compact bs = case decodeField bs of
  Just f  -> Just (encodeField f)
  Nothing -> Nothing

-- url-safe base64 transport (RFC 4648 §5) ----------------------
-- alphabet A-Z a-z 0-9 - _ with = padding; safe in $() and URLs

b64Alphabet :: String
b64Alphabet =
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

bytesToB64 :: [Int] -> String
bytesToB64 = encode
 where
  alpha n = b64Alphabet !! n
  encode []               = []
  encode [a]              =
    [alpha (a `div` 4), alpha ((a `mod` 4) * 16), '=', '=']
  encode [a, b]           =
    [alpha (a `div` 4),
     alpha ((a `mod` 4) * 16 + b `div` 16),
     alpha ((b `mod` 16) * 4),
     '=']
  encode (a : b : c : rest) =
    alpha (a `div` 4) :
    alpha ((a `mod` 4) * 16 + b `div` 16) :
    alpha ((b `mod` 16) * 4 + c `div` 64) :
    alpha (c `mod` 64) :
    encode rest

b64ToBytes :: String -> [Int]
b64ToBytes s = decode (filter (/= '=') s)
 where
  val c = case lookup c (zip b64Alphabet [0 ..]) of
    Just v  -> v
    Nothing -> 0
  decode []                     = []
  decode [_]                    = []
  decode [a, b]                 =
    [val a * 4 + val b `div` 16]
  decode [a, b, c]              =
    [val a * 4 + val b `div` 16,
     (val b `mod` 16) * 16 + val c `div` 4]
  decode (a : b : c : d : rest) =
    (val a * 4 + val b `div` 16) :
    ((val b `mod` 16) * 16 + val c `div` 4) :
    ((val c `mod` 4) * 64 + val d) :
    decode rest
