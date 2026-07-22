-- FFIBridge: the greg-geom executable. The boundary between the
-- Curry core and the machine. Two jobs:
--
--   1. byte transport: bin2hex / hex2bin, so the Curry binary can
--      stay pure-ASCII on its pipes while .greg files stay
--      byte-exact binary CBOR on disk
--   2. numeric kernels: CBOR request on stdin, CBOR reply on
--      stdout (hex framing with -x), for the operations Curry
--      must not hand-roll
--
-- No JSON anywhere. External communication is CBOR via CLI.
module Main ( main ) where

import qualified Codec.CBOR.Read as CR
import qualified Codec.CBOR.Write as CW
import qualified Codec.CBOR.Term as CT
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BC
import qualified Data.ByteString.Lazy as BL
import qualified Data.Text as T
import Data.Char ( digitToInt, isHexDigit, intToDigit )
import Data.Word ( Word8 )
import System.Environment ( getArgs )
import System.Exit ( exitFailure )
import System.IO

import Geometry
import GraphOps
import LinAlg

main :: IO ()
main = do
  mapM_ (`hSetBinaryMode` True) [stdin, stdout]
  args <- getArgs
  case args of
    ["bin2hex"] -> BS.getContents >>= BC.putStrLn . toHex
    ["hex2bin"] -> BS.getContents >>= BS.putStr . fromHex
    ["kernel"]  -> BS.getContents >>= runKernel . fromHex
    ["validate"] -> BS.getContents >>= validate
    _ -> do
      hPutStrLn stderr usage
      exitFailure

usage :: String
usage = unlines
  [ "greg-geom  (the machine half of im-old-greg)"
  , "  bin2hex   stdin binary  -> stdout lowercase hex"
  , "  hex2bin   stdin hex     -> stdout binary"
  , "  kernel    stdin hex CBOR request -> stdout hex CBOR reply"
  , "  validate  stdin binary .greg -> report on stdout"
  ]

-- hex ----------------------------------------------------------

toHex :: BS.ByteString -> BS.ByteString
toHex = BC.pack . concatMap byteHex . BS.unpack
 where
  byteHex w = [ intToDigit (fromIntegral w `div` 16)
              , intToDigit (fromIntegral w `mod` 16) ]

fromHex :: BS.ByteString -> BS.ByteString
fromHex = BS.pack . pairUp . filter isHexDigit . BC.unpack
 where
  pairUp (a : b : rest) = toW a b : pairUp rest
  pairUp _              = []
  toW a b = fromIntegral (digitToInt a * 16 + digitToInt b) :: Word8

-- kernel -------------------------------------------------------
-- request:  [op, args...] as CBOR array
-- reply:    CBOR value, hex on stdout

runKernel :: BS.ByteString -> IO ()
runKernel bs =
  case CR.deserialiseFromBytes CT.decodeTerm (BL.fromStrict bs) of
    Left err -> die' ("kernel: bad CBOR: " ++ show err)
    Right (_, term) -> case dispatch term of
      Just reply ->
        BC.putStrLn (toHex (BL.toStrict (CW.toLazyByteString
                                          (CT.encodeTerm reply))))
      Nothing -> die' "kernel: unknown request"

die' :: String -> IO ()
die' msg = hPutStrLn stderr msg >> exitFailure

dispatch :: CT.Term -> Maybe CT.Term
dispatch t = case t of
  CT.TList (CT.TString op : rest) -> kernelOp (T.unpack op) rest
  CT.TListI (CT.TString op : rest) -> kernelOp (T.unpack op) rest
  _ -> Nothing

kernelOp :: String -> [CT.Term] -> Maybe CT.Term
kernelOp op args = case (op, args) of
  ("chord", [xs, ys]) -> do
    xs' <- floats xs
    ys' <- floats ys
    pure (CT.TDouble (chordLength xs' ys'))
  ("curvature", [pts]) -> do
    pts' <- floatRows pts
    pure (CT.TDouble (sampledCurvature pts'))
  ("triangle-excess", [a, b, c]) -> do
    a' <- floats a
    b' <- floats b
    c' <- floats c
    pure (CT.TDouble (triangleExcess a' b' c'))
  ("frobenius", [r, c, xs, ys]) -> do
    r'  <- int r
    c'  <- int c
    xs' <- floats xs
    ys' <- floats ys
    pure (CT.TDouble (frobenius r' c' xs' ys'))
  ("spectrum", [n, xs]) -> do
    n'  <- int n
    xs' <- floats xs
    pure (CT.TList (map CT.TDouble (spectrum n' xs')))
  ("principal-axis", [r, c, xs]) -> do
    r'  <- int r
    c'  <- int c
    xs' <- floats xs
    pure (CT.TList (map CT.TDouble (principalAxis r' c' xs')))
  ("components", [vs, es]) -> do
    vs' <- ints vs
    es' <- intPairs es
    pure (CT.TInt (componentCount vs' es'))
  ("connected", [vs, es]) -> do
    vs' <- ints vs
    es' <- intPairs es
    pure (CT.TBool (isConnected vs' es'))
  ("degree-profile", [vs, es]) -> do
    vs' <- ints vs
    es' <- intPairs es
    pure (CT.TList (map CT.TInt (degreeProfile vs' es')))
  _ -> Nothing

floats :: CT.Term -> Maybe [Double]
floats t = list t >>= mapM num

floatRows :: CT.Term -> Maybe [[Double]]
floatRows t = list t >>= mapM floats

ints :: CT.Term -> Maybe [Int]
ints t = list t >>= mapM int

intPairs :: CT.Term -> Maybe [(Int, Int)]
intPairs t = list t >>= mapM pair
 where
  pair x = do
    xs <- ints x
    case xs of
      [a, b] -> Just (a, b)
      _      -> Nothing

list :: CT.Term -> Maybe [CT.Term]
list t = case t of
  CT.TList xs  -> Just xs
  CT.TListI xs -> Just xs
  _            -> Nothing

num :: CT.Term -> Maybe Double
num t = case t of
  CT.TDouble d  -> Just d
  CT.THalf f    -> Just (realToFrac f)
  CT.TFloat f   -> Just (realToFrac f)
  CT.TInt n     -> Just (fromIntegral n)
  CT.TInteger n -> Just (fromIntegral n)
  CT.TTagged 4 (CT.TList [e, m]) -> do
    e' <- int e
    m' <- num m
    pure (m' * 10 ^^ e')
  _ -> Nothing

int :: CT.Term -> Maybe Int
int t = case t of
  CT.TInt n     -> Just n
  CT.TInteger n -> Just (fromIntegral n)
  _             -> Nothing

-- validate -----------------------------------------------------

validate :: BS.ByteString -> IO ()
validate bs
  | BS.take 9 bs /= BC.pack "IMOLDGREG" =
      die' "validate: bad magic"
  | otherwise = case BS.uncons (BS.drop 9 bs) of
      Just (1, rest) -> case skipEncodingTag rest of
        Just body -> do
          n <- walk 0 body
          putStrLn ("valid .greg: " ++ show n ++ " records")
        Nothing -> die' "validate: bad encoding tag"
      _ -> die' "validate: unsupported version"
 where
  skipEncodingTag rest =
    case CR.deserialiseFromBytes CT.decodeTerm (BL.fromStrict rest) of
      Right (leftover, CT.TString enc)
        | enc == T.pack "CBOR" -> Just (BL.toStrict leftover)
      _ -> Nothing
  walk :: Int -> BS.ByteString -> IO Int
  walk n body
    | BS.null body = pure n
    | BS.length body < 5 = die' "validate: truncated frame" >> pure n
    | otherwise = do
        let len  = fromIntegral (be32 (BS.take 4 body))
            rec' = BS.take len (BS.drop 4 body)
            rest = BS.drop (4 + len) body
        case CR.deserialiseFromBytes CT.decodeTerm
               (BL.fromStrict (BS.drop 1 rec')) of
          Right (extra, _) | BL.null extra -> walk (n + 1) rest
          _ -> die' ("validate: record " ++ show n
                     ++ " is not clean CBOR") >> pure n
  be32 = BS.foldl' (\a w -> a * 256 + fromIntegral w) (0 :: Integer)
