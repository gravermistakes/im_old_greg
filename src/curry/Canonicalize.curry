-- Canonicalize: concrete -> abstract shape extraction.
-- The mechanism is anti-unification: given instances of a shape,
-- keep what agrees, open a hole where they differ. The result is
-- the invariant: the most specific pattern every instance matches.
--
-- Holes make shapes narrowable: `matchShape` is written so that a
-- free Coord variable can be bound against a Shape by narrowing.
module Canonicalize
  ( Shape (..)
  , shapeOf, antiUnify, invariant
  , matchShape, holeCount, shapeShow
  ) where

import Data.List ( intercalate, sum )

import Wojak

-- a Shape is a Coord with holes
data Shape
  = Hole
  | SScalar   Float
  | SVector   [Shape]
  | SRay      Shape Shape
  | SMatrix   [[Shape]]
  | STensor   [Int] [Shape]
  | SGraph    [Shape] [(Int, Int, Shape)]
  | SLattice  [Shape] [(Int, Int)]
  | SManifold [([Float], Shape)]
 deriving (Eq, Show)

-- the exact shape of one coordinate: no holes yet
shapeOf :: Coord -> Shape
shapeOf c = case c of
  Scalar x      -> SScalar x
  Vector xs     -> SVector (map shapeOf xs)
  Ray o d       -> SRay (shapeOf o) (shapeOf d)
  Matrix rows   -> SMatrix (map (map shapeOf) rows)
  Tensor s xs   -> STensor s (map shapeOf xs)
  Graph ns es   -> SGraph (map shapeOf ns)
                          [ (i, j, shapeOf w) | (i, j, w) <- es ]
  Lattice xs o  -> SLattice (map shapeOf xs) o
  Manifold pts  -> SManifold [ (p, shapeOf v) | (p, v) <- pts ]

-- least general generalization of two shapes
antiUnify :: Shape -> Shape -> Shape
antiUnify a b = case (a, b) of
  (SScalar x, SScalar y)
    | abs (x - y) < 1.0e-9 -> SScalar x
    | otherwise            -> Hole
  (SVector xs, SVector ys)
    | length xs == length ys -> SVector (zipWith antiUnify xs ys)
  (SRay o1 d1, SRay o2 d2)   -> SRay (antiUnify o1 o2)
                                     (antiUnify d1 d2)
  (SMatrix r1, SMatrix r2)
    | map length r1 == map length r2 ->
        SMatrix (zipWith (zipWith antiUnify) r1 r2)
  (STensor s xs, STensor t ys)
    | s == t -> STensor s (zipWith antiUnify xs ys)
  (SGraph n1 e1, SGraph n2 e2)
    | length n1 == length n2 && sameEnds e1 e2 ->
        SGraph (zipWith antiUnify n1 n2)
               [ (i, j, antiUnify w1 w2)
               | ((i, j, w1), (_, _, w2)) <- zip e1 e2 ]
  (SLattice x1 o1, SLattice x2 o2)
    | length x1 == length x2 && o1 == o2 ->
        SLattice (zipWith antiUnify x1 x2) o1
  (SManifold p1, SManifold p2)
    | map fst p1 == map fst p2 ->
        SManifold [ (p, antiUnify v w)
                  | ((p, v), (_, w)) <- zip p1 p2 ]
  _ -> Hole
 where
  sameEnds e1 e2 =
    [ (i, j) | (i, j, _) <- e1 ] == [ (i, j) | (i, j, _) <- e2 ]

-- the invariant across N instances: fold anti-unification
invariant :: [Coord] -> Shape
invariant cs = case map shapeOf cs of
  []       -> Hole
  (s : ss) -> foldl antiUnify s ss

-- does a coordinate inhabit a shape? holes match anything.
matchShape :: Shape -> Coord -> Bool
matchShape s c = case (s, c) of
  (Hole, _)                    -> True
  (SScalar x, Scalar y)        -> abs (x - y) < 1.0e-9
  (SVector ss, Vector xs)      -> allMatch ss xs
  (SRay so sd, Ray o d)        -> matchShape so o && matchShape sd d
  (SMatrix sr, Matrix cr)      ->
    map length sr == map length cr
    && allMatch (concat sr) (concat cr)
  (STensor st ss, Tensor ct xs) -> st == ct && allMatch ss xs
  (SGraph sn se, Graph cn ce)  ->
    allMatch sn cn
    && [ (i, j) | (i, j, _) <- se ] == [ (i, j) | (i, j, _) <- ce ]
    && allMatch [ w | (_, _, w) <- se ] [ w | (_, _, w) <- ce ]
  (SLattice sx so, Lattice cx co) -> so == co && allMatch sx cx
  (SManifold sp, Manifold cp)  ->
    map fst sp == map fst cp
    && allMatch (map snd sp) (map snd cp)
  _ -> False
 where
  allMatch ss xs =
    length ss == length xs && all2 matchShape ss xs
  all2 p xs ys = all (\pr -> p (fst pr) (snd pr)) (zip xs ys)

holeCount :: Shape -> Int
holeCount s = case s of
  Hole          -> 1
  SScalar _     -> 0
  SVector xs    -> sum (map holeCount xs)
  SRay o d      -> holeCount o + holeCount d
  SMatrix rows  -> sum (map holeCount (concat rows))
  STensor _ xs  -> sum (map holeCount xs)
  SGraph ns es  -> sum (map holeCount ns)
                   + sum [ holeCount w | (_, _, w) <- es ]
  SLattice xs _ -> sum (map holeCount xs)
  SManifold pts -> sum [ holeCount v | (_, v) <- pts ]

-- compact rendering for phone-width review
shapeShow :: Shape -> String
shapeShow s = case s of
  Hole          -> "_"
  SScalar x     -> show x
  SVector xs    -> "[" ++ commas (map shapeShow xs) ++ "]"
  SRay o d      -> "ray(" ++ shapeShow o ++ "->" ++ shapeShow d ++ ")"
  SMatrix rows  -> "mat" ++ show (length rows) ++ "x"
                   ++ show (rowLen rows)
  STensor sh _  -> "tensor" ++ show sh
  SGraph ns es  -> "graph(" ++ show (length ns) ++ "n,"
                   ++ show (length es) ++ "e)"
  SLattice xs o -> "lattice(" ++ show (length xs) ++ ","
                   ++ show (length o) ++ ")"
  SManifold pts -> "manifold(" ++ show (length pts) ++ "pts)"
 where
  commas = intercalate ","
  rowLen rows = case rows of
    []      -> 0
    (r : _) -> length r
