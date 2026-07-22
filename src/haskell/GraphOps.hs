-- GraphOps: algebraic-graphs wrappers for structural graph
-- reasoning. Connectivity and reachability come from the
-- library's algebra, never from hand-rolled traversal.
module GraphOps
  ( componentCount
  , isConnected
  , degreeProfile
  ) where

import qualified Algebra.Graph.AdjacencyMap as AM
import qualified Algebra.Graph.AdjacencyMap.Algorithm as Alg
import qualified Algebra.Graph.NonEmpty.AdjacencyMap as NAM
import qualified Data.Set as Set
import Data.List ( sortBy )
import Data.Ord ( comparing, Down (..) )

build :: [Int] -> [(Int, Int)] -> AM.AdjacencyMap Int
build vs es =
  AM.overlays [ AM.vertices vs, AM.edges es, AM.edges backEdges ]
 where
  backEdges = [ (b, a) | (a, b) <- es ]

-- strongly connected components of the symmetrised graph are
-- exactly its connected components
componentCount :: [Int] -> [(Int, Int)] -> Int
componentCount vs es =
  length (AM.vertexList (Alg.scc (build vs es)))

isConnected :: [Int] -> [(Int, Int)] -> Bool
isConnected vs es = componentCount vs es <= 1

-- sorted degree sequence: a cheap graph-shape invariant
degreeProfile :: [Int] -> [(Int, Int)] -> [Int]
degreeProfile vs es =
  sortBy (comparing Down)
    [ Set.size (AM.postSet v g) | v <- vs ]
 where
  g = build vs es

-- silence unused-import warnings while NAM ops are pending
_vertexCountOfComponent :: NAM.AdjacencyMap Int -> Int
_vertexCountOfComponent = NAM.vertexCount
