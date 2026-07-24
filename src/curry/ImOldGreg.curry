-- ImOldGreg: entry point and CLI dispatch.
--
-- Transport contract (kept deliberately narrow):
--   * the current field arrives as hex-encoded .greg bytes on
--     stdin (empty stdin means empty field)
--   * mutating commands print the full new field as hex on stdout
--   * reading commands print a human-readable report
-- The harness (harness/*.sh) owns files and hex<->binary, via
-- the greg-geom helper. This binary never opens a file, so the
-- on-disk .greg stays byte-exact on every platform.
module ImOldGreg where

import System.Environment ( getArgs )
import System.IO ( hGetContents, stdin )

import Cbor
import Wojak
import Metrics
import Canonicalize
import Query
import Analogy
import Storage
import Advisory

main :: IO ()
main = do
  args <- getArgs
  case args of
    []            -> putStr usage
    ("help" : _)  -> putStr usage
    ("types" : _) -> putStr typesReport
    (cmd : rest)  -> do
      hexIn <- hGetContents stdin
      run cmd rest (loadField hexIn)

loadField :: String -> Field
loadField b64In = case decodeField (b64ToBytes b64In) of
  Just f  -> f
  Nothing -> emptyField

emitField :: Field -> IO ()
emitField f = putStrLn (bytesToB64 (encodeField f))

run :: String -> [String] -> Field -> IO ()
run cmd args f = case (cmd, args) of

  ("init", _) -> emitField emptyField

  ("add", (seed : coords)) ->
    emitField (addWojak (mkWojak seed coords) f)

  ("connect", (a : b : rest)) ->
    emitField (connect (CText a) (CText b) (ctxOf rest) f)

  ("set-coord", (seed : ax : val : _)) ->
    emitField (setCoord (CText seed) ax (parseCoord val) f)

  ("list", _) -> putStr (listReport f)

  ("query", (seed : rest)) ->
    putStr (fieldReport f (CText seed) (stepsOf rest))

  ("relate", (a : b : _)) ->
    putStr (relateReport f (CText a) (CText b))

  ("analogy", (a : b : c : _)) ->
    putStr (analogyReport f (CText a) (CText b) (CText c))

  ("triangulate", seeds@(_ : _ : _)) ->
    putStr (triangulateReport f (map CText seeds))

  ("shape", (seed : ax : _)) ->
    putStr (shapeReport f (CText seed) ax)

  ("advisory", _) ->
    putStr (renderAdvisories (fieldAdvisories f))

  ("compact", _) ->
    case compact (encodeField f) of
      Just bs -> putStrLn (bytesToHex bs)
      Nothing -> putStr "compact: field did not decode\n"

  _ -> putStr usage

-- builders -----------------------------------------------------

mkWojak :: String -> [String] -> Wojak
mkWojak seed coords = Wojak
  { wjSeed   = CText seed
  , wjCoords = map pair coords
  , wjState  = []
  }
 where
  pair s = case break (== '=') s of
    (ax, '=' : v) -> (ax, parseCoord v)
    (ax, _)       -> (ax, Scalar 1.0)

-- axis=1.5 | axis=1,2,3 (vector) | bare axis (presence)
parseCoord :: String -> Coord
parseCoord v = case splitCommas v of
  [x] -> Scalar (readF x)
  xs  -> Vector (map (Scalar . readF) xs)

splitCommas :: String -> [String]
splitCommas s = case break (== ',') s of
  (x, [])       -> [x]
  (x, _ : rest) -> x : splitCommas rest

readF :: String -> Float
readF s = case s of
  ('-' : r) -> - (readPos r)
  _         -> readPos s
 where
  readPos t = case break (== '.') t of
    (i, [])        -> fromInt (readI i)
    (i, _ : fr)    -> fromInt (readI i)
                      + fromInt (readI fr) / tenPow (length fr)
  readI = foldl (\a c -> a * 10 + (ord c - ord '0')) 0
  tenPow n = if n <= 0 then 1.0 else 10.0 * tenPow (n - 1)

ctxOf :: [String] -> CborValue
ctxOf rest = case rest of
  []      -> cmap [("relation", CText "lateral")]
  (r : _) -> cmap [("relation", CText r)]

stepsOf :: [String] -> Int
stepsOf rest = case rest of
  []      -> 4
  (n : _) -> foldl (\a c -> a * 10 + (ord c - ord '0')) 0 n

-- reports --------------------------------------------------------

listReport :: Field -> String
listReport f = unlines
  ( ("wojaks: " ++ show (length (fWojaks f))
     ++ "  connections: " ++ show (length (fConns f))
     ++ "  axes: " ++ show (fieldDims f)
     ++ dimNote)
  : [ "  " ++ seedText (wjSeed w) ++ "  ["
      ++ unwordsC (map fst (wjCoords w)) ++ "]"
    | w <- fWojaks f ] )
 where
  dimNote
    | dimDeficit f > 0 = "  (deficit " ++ show (dimDeficit f)
                         ++ " below " ++ show minFieldDims ++ ")"
    | otherwise        = ""
  unwordsC = foldr joinC ""
  joinC x acc = if null acc then x else x ++ " " ++ acc

relateReport :: Field -> Seed -> Seed -> String
relateReport f a b =
  case (wojakBySeed f a, wojakBySeed f b) of
    (Just wa, Just wb) -> unlines
      ( ("relate " ++ seedText a ++ " <-> " ++ seedText b)
      : ("relatedness: " ++ show (relatedness f a b))
      : concat
          [ ("axis " ++ ax ++ " (dist "
             ++ show (coordDist ca cb) ++ "):")
            : [ "  " ++ show m ++ ": " ++ show v
              | (m, v) <- morphisms ca cb, v /= Absent ]
          | (ax, ca) <- wjCoords wa
          , Just cb <- [getCoord wb ax] ] )
    _ -> "relate: unknown seed\n"

analogyReport :: Field -> Seed -> Seed -> Seed -> String
analogyReport f a b c = unlines
  ( (seedText a ++ " : " ++ seedText b ++ " :: "
     ++ seedText c ++ " : ?")
  : [ "  " ++ seedText s ++ "  (mismatch " ++ show d ++ ")"
    | (s, d) <- take 5 (analogy f a b c) ] )

triangulateReport :: Field -> [Seed] -> String
triangulateReport f seeds = unlines
  ( "invariant across instances:"
  : [ "  " ++ ax ++ ": " ++ shapeShow sh | (ax, sh) <- pat ]
  ++ "matches elsewhere in the field:"
  : [ "  " ++ seedText s | s <- found ] )
 where
  pat   = triangulate f seeds
  found = shapeInstances f pat seeds

shapeReport :: Field -> Seed -> String -> String
shapeReport f s ax = case wojakBySeed f s of
  Just w -> case getCoord w ax of
    Just c -> "shape of " ++ seedText s ++ " on " ++ ax ++ ":\n  "
              ++ shapeShow (shapeOf c) ++ "\n"
              ++ "  depth " ++ show (coordDepth c)
              ++ ", dims " ++ show (coordDims c) ++ "\n"
    Nothing -> "no coordinate on axis " ++ ax ++ "\n"
  Nothing -> "unknown seed\n"

typesReport :: String
typesReport = unlines
  ( ("the " ++ show relationCount ++ " relationship types (locked):")
  : [ "  " ++ relationName r | r <- allRelations ] )

usage :: String
usage = unlines
  [ "im-old-greg  (field arrives as hex .greg on stdin)"
  , ""
  , "  init                        emit an empty field"
  , "  add SEED [ax=v ...]         grow a wojak (connects to isness)"
  , "  connect A B [relation]      lateral connection"
  , "  set-coord SEED AXIS VALUE   place a coordinate"
  , "  list                        field summary"
  , "  query SEED [steps]          diffuse signal from a seed"
  , "  relate A B                  morphisms + relatedness"
  , "  analogy A B C               A : B :: C : ?"
  , "  triangulate S1 S2 [...]     invariant + matches"
  , "  shape SEED AXIS             canonical shape of a coordinate"
  , "  advisory                    what the field surfaces about itself"
  , "  compact                     fold accretion, emit hex"
  , "  types                       the 29 relationship types"
  ]
