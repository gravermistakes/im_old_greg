-- TestWikiSeeds: the seven random articles as wojaks.
-- Checks the field they make, and checks that they were not
-- forced onto shared axes they do not naturally occupy.
module TestWikiSeeds where

import Data.List ( nub )

import Wojak
import WikiSeeds

check :: String -> Bool -> IO ()
check name ok =
  if ok then putStrLn ("ok " ++ name)
        else error ("FAIL " ++ name)

grafted :: Field
grafted = graftWikiSeeds emptyField

-- how many of the seven hold a coordinate on an axis
occupancy :: String -> Int
occupancy ax =
  length [w | w <- wikiWojaks, getCoord w ax /= Nothing]

allAxes :: [String]
allAxes = nub (concatMap (map fst . wjCoords) wikiWojaks)

lateralDegree :: Seed -> Int
lateralDegree s =
  length [ c | c <- fConns grafted
             , (cnA c == s && cnB c /= motherSeed)
               || (cnB c == s && cnA c /= motherSeed) ]

main :: IO ()
main = do
  check "seven wojaks plus isness"
    (length (fWojaks grafted) == 8)
  check "every seed is distinct"
    (length (nub wikiSeeds) == 7)
  check "the field clears the 31-axis floor"
    (dimDeficit grafted == 0)
  check "no wojak is left touching only isness"
    (all (\w -> lateralDegree (wjSeed w) > 0) wikiWojaks)
  check "no wojak is all bare scalars"
    (all (not . allScalar) wikiWojaks)
  check "every wojak carries its provenance"
    (all (\w -> lookup "source" (wjState w) /= Nothing) wikiWojaks)

  -- the operator's rule: axes are taken, not handed out
  check "most axes carry one occupant"
    (length [ax | ax <- allAxes, occupancy ax == 1]
       > length [ax | ax <- allAxes, occupancy ax > 1])
  check "only record is shared by all seven"
    ([ax | ax <- allAxes, occupancy ax == 7] == ["record"])
  check "shared axes agree on coordinate type"
    (all sameTypeAcross [ax | ax <- allAxes, occupancy ax > 1])

  -- grafting twice must not double anything
  check "regraft adds no wojak"
    (length (fWojaks (graftWikiSeeds grafted))
       == length (fWojaks grafted))
  check "regraft adds no connection"
    (length (fConns (graftWikiSeeds grafted))
       == length (fConns grafted))
 where
  allScalar w = all (isScalar . snd) (wjCoords w)
  isScalar c = case c of
    Scalar _ -> True
    _        -> False
  sameTypeAcross ax =
    length (nub [coordType c | w <- wikiWojaks
                             , Just c <- [getCoord w ax]]) == 1
