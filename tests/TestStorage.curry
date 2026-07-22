-- TestStorage: CBOR codec round-trips, .greg framing survives
-- encode/decode, accretion replays, hex transport is lossless.
module TestStorage where

import Cbor
import Axes
import Memo
import Storage
import Witness

check :: String -> Bool -> IO ()
check name ok =
  if ok then putStrLn ("ok " ++ name)
        else error ("FAIL " ++ name)

roundtrip :: CborValue -> Bool
roundtrip v = decodeFull (encode v) == Just v

main :: IO ()
main = do
  check "cbor int roundtrip" (roundtrip (CInt 42))
  check "cbor negative int" (roundtrip (CInt (-1000)))
  check "cbor big int" (roundtrip (CInt 4294967297))
  check "cbor text" (roundtrip (CText "isness"))
  check "cbor unicode text" (roundtrip (CText "wojak\8734"))
  check "cbor bytes" (roundtrip (CBytes [0, 127, 255]))
  check "cbor list" (roundtrip (CList [CInt 1, CText "a", CNull]))
  check "cbor map"
    (roundtrip (cmap [("k", CInt 1), ("l", CBool True)]))
  check "cbor tag" (roundtrip (CTag 99 (CInt 7)))
  check "cbor float via decimal fraction"
    (case decodeFull (encode (CFloat 3.25)) of
       Just (CFloat f) -> abs (f - 3.25) < 1.0e-9
       _               -> False)
  check "cbor ieee float64 decodes"
    -- 0xfb 3ff0000000000000 = 1.0
    (case decode [251, 63, 240, 0, 0, 0, 0, 0, 0] of
       Just (CFloat f, []) -> abs (f - 1.0) < 1.0e-12
       _                   -> False)

  check "hex transport lossless"
    (hexToBytes (bytesToHex [0, 15, 16, 200, 255])
       == [0, 15, 16, 200, 255])

  let f0 = emptyField
      f1 = addWojak (Wojak (CText "dolphin")
             [("trophic-level", Scalar 3.0)] []) f0
      f2 = connect (CText "dolphin") (CText "isness")
             (cmap [("relation", CText "test")]) f1
  check "field roundtrips through .greg bytes"
    (decodeField (encodeField f2) == Just f2)
  check "empty bytes do not decode" (decodeField [] == Nothing)
  check "compact preserves the field"
    (compact (encodeField f2) == Just (encodeField f2))

  -- accretion: a later node record with the same seed merges
  let bytes  = encodeField f1
      extra  = appendRecords bytes
                 [ NodeRec (wojakToCbor (Wojak (CText "dolphin")
                     [("habitat", Vector [Scalar 1.0])] [])) ]
  check "append-only accretion merges coords"
    (case decodeField extra of
       Just f -> case wojakBySeed f (CText "dolphin") of
         Just w -> getCoord w "habitat" /= Nothing
                   && getCoord w "trophic-level" /= Nothing
         Nothing -> False
       Nothing -> False)

  -- witness mesh
  let m0 = encodeMesh [Observation [] (CText "first light")]
      m1 = appendObs m0 (Observation [0] (CText "saw the first"))
      obs = decodeMesh m1
  check "witness mesh appends and decodes" (length obs == 2)
  check "corroboration counts references"
    (corroboration obs 0 == 1 && corroboration obs 1 == 0)
  check "unwitnessed finds the growing edge"
    (unwitnessed obs == [1])
  putStrLn "TestStorage: all passed"
