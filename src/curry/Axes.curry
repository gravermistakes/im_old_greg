-- Axes: first-class axes and typed, recursively nested coordinates.
-- Axes belong to no memo. Wojaks create axes by having coordinates
-- on them. Distance is type-aware and recursive; it never flattens
-- a coordinate to a scalar.
--
-- Numeric kernels here are structural recursions with scalar
-- arithmetic at the leaves. Heavy differential geometry (true
-- geodesics, curvature tensors) is delegated to the greg-geom
-- helper at the harness layer.
module Axes
  ( Coord (..), Axis (..), CoordType (..)
  , coordType, coordDist, coordDepth, coordDims
  , scaleCoord, blendCoord
  , coordToCbor, coordFromCbor
  , minFieldDims
  ) where

import Data.List ( sum )

import Cbor

-- the eight coordinate types, nesting recursively
data Coord
  = Scalar   Float
  | Vector   [Coord]
  | Ray      Coord Coord            -- origin, direction (irreversible)
  | Matrix   [[Coord]]
  | Tensor   [Int] [Coord]          -- shape, row-major cells
  | Graph    [Coord] [(Int, Int, Coord)]  -- node payloads, weighted edges
  | Lattice  [Coord] [(Int, Int)]   -- elements, covering pairs (a <= b)
  | Manifold [([Float], Coord)]     -- sampled chart: point -> fibre value
 deriving (Eq, Show)

data CoordType
  = TScalar | TVector | TRay | TMatrix
  | TTensor | TGraph | TLattice | TManifold
 deriving (Eq, Show)

data Axis = Axis
  { axisName :: String
  , axisType :: CoordType
  }
 deriving (Eq, Show)

-- the field is degenerate below 31 axes
minFieldDims :: Int
minFieldDims = 31

coordType :: Coord -> CoordType
coordType c = case c of
  Scalar _     -> TScalar
  Vector _     -> TVector
  Ray _ _      -> TRay
  Matrix _     -> TMatrix
  Tensor _ _   -> TTensor
  Graph _ _    -> TGraph
  Lattice _ _  -> TLattice
  Manifold _   -> TManifold

-- recursive embedding depth of a coordinate
coordDepth :: Coord -> Int
coordDepth c = case c of
  Scalar _      -> 0
  Vector xs     -> 1 + maxOr0 (map coordDepth xs)
  Ray o d       -> 1 + max (coordDepth o) (coordDepth d)
  Matrix rows   -> 1 + maxOr0 (map coordDepth (concat rows))
  Tensor _ xs   -> 1 + maxOr0 (map coordDepth xs)
  Graph ns es   -> 1 + maxOr0 (map coordDepth ns
                               ++ [coordDepth w | (_, _, w) <- es])
  Lattice xs _  -> 1 + maxOr0 (map coordDepth xs)
  Manifold pts  -> 1 + maxOr0 [coordDepth v | (_, v) <- pts]

-- how many scalar degrees of freedom a coordinate carries
coordDims :: Coord -> Int
coordDims c = case c of
  Scalar _      -> 1
  Vector xs     -> sum (map coordDims xs)
  Ray o d       -> coordDims o + coordDims d
  Matrix rows   -> sum (map coordDims (concat rows))
  Tensor _ xs   -> sum (map coordDims xs)
  Graph ns es   -> sum (map coordDims ns)
                   + sum [coordDims w | (_, _, w) <- es]
  Lattice xs _  -> sum (map coordDims xs)
  Manifold pts  -> sum [length p + coordDims v | (p, v) <- pts]

-- type-aware recursive distance -------------------------------
-- Same-typed coordinates recurse structurally. Differently typed
-- coordinates are compared through their spectra of leaf scalars,
-- scaled by a type-mismatch penalty: distant in kind, but never
-- incomparable. Nothing in the field is incomparable.

coordDist :: Coord -> Coord -> Float
coordDist a b = case (a, b) of
  (Scalar x, Scalar y)         -> abs (x - y)
  (Vector xs, Vector ys)       -> l2 (zipDist xs ys)
  (Ray o1 d1, Ray o2 d2)       -> coordDist o1 o2 + coordDist d1 d2
  (Matrix r1, Matrix r2)       -> l2 (zipDist (concat r1) (concat r2))
  (Tensor s1 x1, Tensor s2 x2)
    | s1 == s2  -> l2 (zipDist x1 x2)
    | otherwise -> spectralDist a b
  (Graph n1 e1, Graph n2 e2)   ->
    l2 (zipDist n1 n2) + edgeDist e1 e2
  (Lattice x1 o1, Lattice x2 o2) ->
    l2 (zipDist x1 x2) + fromInt (orderDiff o1 o2)
  (Manifold p1, Manifold p2)   -> chartDist p1 p2
  _                            -> typePenalty * spectralDist a b
 where
  typePenalty = 2.0

zipDist :: [Coord] -> [Coord] -> [Float]
zipDist xs ys =
  [ coordDist x y | (x, y) <- zip xs ys ]
  ++ [ coordNorm z | z <- drop n xs ++ drop n ys ]
 where n = min (length xs) (length ys)

edgeDist :: [(Int, Int, Coord)] -> [(Int, Int, Coord)] -> Float
edgeDist e1 e2 =
  sum [ gap e | e <- e1 ]
  + sum [ coordNorm w | (i, j, w) <- e2, not (hasEdge i j e1) ]
 where
  gap (i, j, w) = case weightsAt i j e2 of
    []       -> coordNorm w
    (w2 : _) -> coordDist w w2
  weightsAt i j es =
    [ w | (x, y, w) <- es, sameEnds i j x y ]
  hasEdge i j es = any (\(x, y, _) -> sameEnds i j x y) es
  sameEnds i j x y = (i == x && j == y) || (i == y && j == x)

orderDiff :: [(Int, Int)] -> [(Int, Int)] -> Int
orderDiff o1 o2 =
  length [ p | p <- o1, notElem p o2 ]
  + length [ p | p <- o2, notElem p o1 ]

chartDist :: [([Float], Coord)] -> [([Float], Coord)] -> Float
chartDist p1 p2 =
  meanOr0 [ nearest pt p2 | pt <- p1 ]
  + meanOr0 [ nearest pt p1 | pt <- p2 ]
 where
  nearest (xs, v) pts =
    minOrBig [ l2 (zipWith (-) xs ys) + coordDist v w
             | (ys, w) <- pts ]

-- flat spectrum of leaf scalars, for cross-type comparison
leaves :: Coord -> [Float]
leaves c = case c of
  Scalar x      -> [x]
  Vector xs     -> concatMap leaves xs
  Ray o d       -> leaves o ++ leaves d
  Matrix rows   -> concatMap leaves (concat rows)
  Tensor _ xs   -> concatMap leaves xs
  Graph ns es   -> concatMap leaves ns
                   ++ concat [leaves w | (_, _, w) <- es]
  Lattice xs _  -> concatMap leaves xs
  Manifold pts  -> concat [p ++ leaves v | (p, v) <- pts]

spectralDist :: Coord -> Coord -> Float
spectralDist a b = l2 (zipPad (leaves a) (leaves b))
 where
  zipPad xs ys =
    zipWith (-) xs ys
    ++ drop n xs ++ drop n ys
   where n = min (length xs) (length ys)

coordNorm :: Coord -> Float
coordNorm c = l2 (leaves c)

l2 :: [Float] -> Float
l2 xs = sqrt (sum (map (\x -> x * x) xs))

maxOr0 :: [Int] -> Int
maxOr0 xs = if null xs then 0 else foldr1 max xs

meanOr0 :: [Float] -> Float
meanOr0 xs =
  if null xs then 0.0 else sum xs / fromInt (length xs)

minOrBig :: [Float] -> Float
minOrBig xs = if null xs then 1.0e9 else foldr1 min xs

-- simple structural transforms --------------------------------

scaleCoord :: Float -> Coord -> Coord
scaleCoord k c = case c of
  Scalar x      -> Scalar (k * x)
  Vector xs     -> Vector (map (scaleCoord k) xs)
  Ray o d       -> Ray (scaleCoord k o) (scaleCoord k d)
  Matrix rows   -> Matrix (map (map (scaleCoord k)) rows)
  Tensor s xs   -> Tensor s (map (scaleCoord k) xs)
  Graph ns es   -> Graph (map (scaleCoord k) ns)
                         [ (i, j, scaleCoord k w) | (i, j, w) <- es ]
  Lattice xs o  -> Lattice (map (scaleCoord k) xs) o
  Manifold pts  -> Manifold [ (map (k *) p, scaleCoord k v)
                            | (p, v) <- pts ]

-- midpoint blend where structures align; left survives elsewhere
blendCoord :: Coord -> Coord -> Coord
blendCoord a b = case (a, b) of
  (Scalar x, Scalar y)   -> Scalar ((x + y) / 2.0)
  (Vector xs, Vector ys) -> Vector (zipWith blendCoord xs ys)
  (Ray o1 d1, Ray o2 d2) -> Ray (blendCoord o1 o2) (blendCoord d1 d2)
  (Matrix r1, Matrix r2) -> Matrix (zipWith (zipWith blendCoord) r1 r2)
  (Tensor s xs, Tensor t ys)
    | s == t    -> Tensor s (zipWith blendCoord xs ys)
    | otherwise -> a
  _ -> a

-- CBOR mapping -------------------------------------------------

coordToCbor :: Coord -> CborValue
coordToCbor c = case c of
  Scalar x     -> CList [CText "scalar", CFloat x]
  Vector xs    -> CList [CText "vector", CList (map coordToCbor xs)]
  Ray o d      -> CList [CText "ray", coordToCbor o, coordToCbor d]
  Matrix rows  -> CList [ CText "matrix"
                        , CList [ CList (map coordToCbor r)
                                | r <- rows ] ]
  Tensor s xs  -> CList [ CText "tensor"
                        , CList (map CInt s)
                        , CList (map coordToCbor xs) ]
  Graph ns es  -> CList [ CText "graph"
                        , CList (map coordToCbor ns)
                        , CList [ CList [CInt i, CInt j, coordToCbor w]
                                | (i, j, w) <- es ] ]
  Lattice xs o -> CList [ CText "lattice"
                        , CList (map coordToCbor xs)
                        , CList [ CList [CInt i, CInt j]
                                | (i, j) <- o ] ]
  Manifold pts -> CList [ CText "manifold"
                        , CList [ CList [ CList (map CFloat p)
                                        , coordToCbor v ]
                                | (p, v) <- pts ] ]

coordFromCbor :: CborValue -> Maybe Coord
coordFromCbor v = case v of
  CList [CText "scalar", CFloat x] -> Just (Scalar x)
  CList [CText "scalar", CInt n]   -> Just (Scalar (fromInt n))
  CList [CText "vector", CList xs] ->
    Vector <$> mapM coordFromCbor xs
  CList [CText "ray", o, d] ->
    case (coordFromCbor o, coordFromCbor d) of
      (Just o', Just d') -> Just (Ray o' d')
      _                  -> Nothing
  CList [CText "matrix", CList rows] ->
    Matrix <$> mapM rowFrom rows
   where
    rowFrom r = case r of
      CList cs -> mapM coordFromCbor cs
      _        -> Nothing
  CList [CText "tensor", CList s, CList xs] ->
    case (mapM intFrom s, mapM coordFromCbor xs) of
      (Just s', Just xs') -> Just (Tensor s' xs')
      _                   -> Nothing
  CList [CText "graph", CList ns, CList es] ->
    case (mapM coordFromCbor ns, mapM edgeFrom es) of
      (Just ns', Just es') -> Just (Graph ns' es')
      _                    -> Nothing
   where
    edgeFrom e = case e of
      CList [CInt i, CInt j, w] ->
        case coordFromCbor w of
          Just w' -> Just (i, j, w')
          Nothing -> Nothing
      _ -> Nothing
  CList [CText "lattice", CList xs, CList o] ->
    case (mapM coordFromCbor xs, mapM pairFrom o) of
      (Just xs', Just o') -> Just (Lattice xs' o')
      _                   -> Nothing
   where
    pairFrom p = case p of
      CList [CInt i, CInt j] -> Just (i, j)
      _                      -> Nothing
  CList [CText "manifold", CList pts] ->
    Manifold <$> mapM ptFrom pts
   where
    ptFrom p = case p of
      CList [CList fs, w] ->
        case (mapM floatFrom fs, coordFromCbor w) of
          (Just fs', Just w') -> Just (fs', w')
          _                   -> Nothing
      _ -> Nothing
  _ -> Nothing

intFrom :: CborValue -> Maybe Int
intFrom x = case x of
  CInt n -> Just n
  _      -> Nothing

floatFrom :: CborValue -> Maybe Float
floatFrom x = case x of
  CFloat f -> Just f
  CInt n   -> Just (fromInt n)
  _        -> Nothing
