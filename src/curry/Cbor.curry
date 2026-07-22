-- Cbor: pure Curry CBOR codec over byte lists.
-- Bytes are Ints in 0..255. No file IO here; transport is
-- the harness's job (greg-geom hex2bin/bin2hex).
-- Floats are written as decimal fractions (tag 4) so we never
-- hand-assemble IEEE754. We still decode incoming IEEE floats.
module Cbor
  ( CborValue (..)
  , encode, decode, decodeFull
  , cborLookup, cmap, ctext
  ) where

import Data.List ( splitOn )

data CborValue
  = CInt   Int
  | CFloat Float
  | CText  String
  | CBytes [Int]
  | CList  [CborValue]
  | CMap   [(CborValue, CborValue)]
  | CTag   Int CborValue
  | CBool  Bool
  | CNull
 deriving (Eq, Show)

-- small helpers ------------------------------------------------

ctext :: String -> CborValue
ctext = CText

cmap :: [(String, CborValue)] -> CborValue
cmap kvs = CMap [ (CText k, v) | (k, v) <- kvs ]

cborLookup :: String -> CborValue -> Maybe CborValue
cborLookup k v = case v of
  CMap kvs -> lookup (CText k) kvs
  _        -> Nothing

-- encoding -----------------------------------------------------

encode :: CborValue -> [Int]
encode v = case v of
  CInt n     -> if n >= 0 then head0 0 n else head0 1 (-1 - n)
  CFloat f   -> encodeFloat f
  CText s    -> let bs = utf8 s in head0 3 (length bs) ++ bs
  CBytes bs  -> head0 2 (length bs) ++ bs
  CList xs   -> head0 4 (length xs) ++ concatMap encode xs
  CMap kvs   -> head0 5 (length kvs)
                ++ concat [ encode k ++ encode w | (k, w) <- kvs ]
  CTag t x   -> head0 6 t ++ encode x
  CBool b    -> [if b then 245 else 244]
  CNull      -> [246]

-- major type + unsigned argument
head0 :: Int -> Int -> [Int]
head0 m n
  | n < 24         = [m * 32 + n]
  | n < 256        = [m * 32 + 24, n]
  | n < 65536      = m * 32 + 25 : beBytes 2 n
  | n < 4294967296 = m * 32 + 26 : beBytes 4 n
  | otherwise      = m * 32 + 27 : beBytes 8 n

beBytes :: Int -> Int -> [Int]
beBytes k n = reverse (take k (leBytes n))
 where
  leBytes x = x `mod` 256 : leBytes (x `div` 256)

-- Float -> tag 4 decimal fraction [exponent, mantissa],
-- derived from show so the decimal digits are exact.
encodeFloat :: Float -> [Int]
encodeFloat f = encode (CTag 4 (CList [CInt e, CInt m]))
 where
  (e, m) = decimalParts (show f)

decimalParts :: String -> (Int, Int)
decimalParts s0 = (ePart - length frac, signed digits)
 where
  (neg, s1)    = case s0 of
                   '-' : r -> (True, r)
                   _       -> (False, s0)
  (base, ex)   = case splitOn "e" s1 of
                   [b, x] -> (b, readInt x)
                   _      -> (s1, 0)
  (int_, frac) = case splitOn "." base of
                   [i, fr] -> (i, fr)
                   _       -> (base, "")
  ePart        = ex
  digits       = readInt (int_ ++ frac)
  signed d     = if neg then -d else d

readInt :: String -> Int
readInt s = case s of
  '-' : r -> - (digitsVal r)
  '+' : r -> digitsVal r
  _       -> digitsVal s
 where
  digitsVal = foldl (\a c -> a * 10 + (ord c - ord '0')) 0

-- utf8 ---------------------------------------------------------

utf8 :: String -> [Int]
utf8 = concatMap enc
 where
  enc c
    | n < 128   = [n]
    | n < 2048  = [192 + n `div` 64, 128 + n `mod` 64]
    | n < 65536 = [ 224 + n `div` 4096
                  , 128 + (n `div` 64) `mod` 64
                  , 128 + n `mod` 64 ]
    | otherwise = [ 240 + n `div` 262144
                  , 128 + (n `div` 4096) `mod` 64
                  , 128 + (n `div` 64) `mod` 64
                  , 128 + n `mod` 64 ]
   where n = ord c

unUtf8 :: [Int] -> String
unUtf8 bs = case bs of
  []       -> ""
  b : rest
    | b < 128   -> chr b : unUtf8 rest
    | b < 224   -> cont 1 (b - 192) rest
    | b < 240   -> cont 2 (b - 224) rest
    | otherwise -> cont 3 (b - 240) rest
 where
  cont k acc rest =
    let (cs, rest') = splitAt k rest
        n = foldl (\a c -> a * 64 + (c - 128)) acc cs
    in chr n : unUtf8 rest'

-- decoding -----------------------------------------------------

decodeFull :: [Int] -> Maybe CborValue
decodeFull bs = case decode bs of
  Just (v, []) -> Just v
  _            -> Nothing

decode :: [Int] -> Maybe (CborValue, [Int])
decode []       = Nothing
decode (b : bs) = decodeItem (b `div` 32) (b `mod` 32) bs

decodeItem :: Int -> Int -> [Int] -> Maybe (CborValue, [Int])
decodeItem major ai bs = case major of
  0 -> withArg (\n r -> Just (CInt n, r))
  1 -> withArg (\n r -> Just (CInt (-1 - n), r))
  2 -> withArg (\n r -> let (xs, r') = splitAt n r
                        in Just (CBytes xs, r'))
  3 -> withArg (\n r -> let (xs, r') = splitAt n r
                        in Just (CText (unUtf8 xs), r'))
  4 -> withArg (\n r -> decodeN n r [])
  5 -> withArg (\n r -> decodePairs n r [])
  6 -> withArg (\n r -> case decode r of
                          Just (v, r') -> Just (untag n v, r')
                          Nothing      -> Nothing)
  7 -> decodeSimple ai bs
  _ -> Nothing
 where
  withArg k = case argVal ai bs of
    Just (n, r) -> k n r
    Nothing     -> Nothing

decodeN :: Int -> [Int] -> [CborValue] -> Maybe (CborValue, [Int])
decodeN n bs acc
  | n == 0    = Just (CList (reverse acc), bs)
  | otherwise = case decode bs of
      Just (v, r) -> decodeN (n - 1) r (v : acc)
      Nothing     -> Nothing

decodePairs :: Int -> [Int] -> [(CborValue, CborValue)]
            -> Maybe (CborValue, [Int])
decodePairs n bs acc
  | n == 0    = Just (CMap (reverse acc), bs)
  | otherwise = case decode bs of
      Just (k, r) -> case decode r of
        Just (v, r') -> decodePairs (n - 1) r' ((k, v) : acc)
        Nothing      -> Nothing
      Nothing -> Nothing

argVal :: Int -> [Int] -> Maybe (Int, [Int])
argVal ai bs
  | ai < 24   = Just (ai, bs)
  | ai == 24  = grab 1
  | ai == 25  = grab 2
  | ai == 26  = grab 4
  | ai == 27  = grab 8
  | otherwise = Nothing
 where
  grab k
    | length bs >= k =
        let (xs, r) = splitAt k bs
        in Just (foldl (\a x -> a * 256 + x) 0 xs, r)
    | otherwise = Nothing

-- tag 4 comes back as a Float; other tags stay wrapped
untag :: Int -> CborValue -> CborValue
untag t v = case (t, v) of
  (4, CList [CInt e, CInt m]) -> CFloat (fromInt m * pow10 e)
  _                           -> CTag t v

decodeSimple :: Int -> [Int] -> Maybe (CborValue, [Int])
decodeSimple ai bs = case ai of
  20 -> Just (CBool False, bs)
  21 -> Just (CBool True, bs)
  22 -> Just (CNull, bs)
  25 -> ieee 2 halfVal
  26 -> ieee 4 (floatVal 8 23)
  27 -> ieee 8 (floatVal 11 52)
  _  -> Nothing
 where
  ieee k conv
    | length bs >= k =
        let (xs, r) = splitAt k bs
        in Just (CFloat (conv (foldl (\a x -> a * 256 + x) 0 xs)), r)
    | otherwise = Nothing

halfVal :: Int -> Float
halfVal = floatVal 5 10

-- generic IEEE754 binary decode: eb exponent bits, mb mantissa bits
floatVal :: Int -> Int -> Int -> Float
floatVal eb mb w = sign * mag
 where
  mant  = w `mod` twoP mb
  expo  = (w `div` twoP mb) `mod` twoP eb
  sign  = if w `div` twoP (mb + eb) == 1 then -1.0 else 1.0
  bias  = twoP (eb - 1) - 1
  mfrac = fromInt mant / fromInt (twoP mb)
  mag
    | expo == 0 = mfrac * pow2 (1 - bias)
    | otherwise = (1.0 + mfrac) * pow2 (expo - bias)

twoP :: Int -> Int
twoP n = if n <= 0 then 1 else 2 * twoP (n - 1)

pow2 :: Int -> Float
pow2 n
  | n >= 0    = fromInt (twoP n)
  | otherwise = 1.0 / fromInt (twoP (-n))

pow10 :: Int -> Float
pow10 n
  | n == 0    = 1.0
  | n > 0     = 10.0 * pow10 (n - 1)
  | otherwise = pow10 (n + 1) / 10.0
