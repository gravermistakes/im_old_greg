-- WikiSeeds: seven wojaks drawn at random from en.wikipedia.
--
-- Sampling: Special:Random, seven pulls, 2026-07-25. Nothing was
-- filtered, swapped, or retried. What the coin gave is what grew.
--
-- Coordinates come from what each article actually states. Axes
-- are not handed out evenly: a wojak takes an axis only where its
-- own content puts it there, so most axes here carry one or two
-- occupants and the overlaps that exist are real ones. The single
-- axis all seven share is `record`, and only because all seven
-- were drawn from the same corpus.
module WikiSeeds
  ( wikiWojaks, wikiLinks, wikiSeeds
  , graftWikiSeeds
  ) where

import Cbor
import Wojak

-- ---- terse constructors --------------------------------------

sc :: Float -> Coord
sc = Scalar

vec :: [Float] -> Coord
vec xs = Vector (map Scalar xs)

chain :: [Float] -> Coord
chain xs = Lattice (map Scalar xs) links
 where
  links = [(i, i + 1) | i <- [0 .. length xs - 2]]

provenance :: String -> String -> [(String, CborValue)]
provenance title url =
  [ ("title",     CText title)
  , ("source",    CText url)
  , ("corpus",    CText "en.wikipedia.org")
  , ("sampled",   CText "Special:Random")
  , ("retrieved", CText "2026-07-25")
  ]

-- ---- 1. an adaptation ----------------------------------------

theOfficeAu :: Wojak
theOfficeAu = Wojak
  { wjSeed = CText "the-office-au"
  , wjCoords =
      [ ("adaptation-lineage", Ray (sc 2001.0) (sc 2024.0))
      , ("mimesis", sc 0.85)          -- mockumentary imitating record
      , ("ensemble", ensemble)
      , ("serial-extent", vec [1.0, 8.0])        -- seasons, episodes
      , ("broadcast", vec [0.0, 1.0, 0.0])  -- terrestrial, stream, live
      , ("production-consortium", triangleGraph)
      , ("workplace-hierarchy", chain [0.0, 1.0, 2.0])
      , ("dissolution-pressure", sc 0.9)  -- the branch is being closed
      , ("record", vec [18.1, 36.0])
      ]
  , wjState = provenance "The Office (Australian TV series)"
      "https://en.wikipedia.org/wiki/The_Office_(Australian_TV_series)"
  }
 where
  -- one lead, fourteen named supporting, all bound to the lead
  ensemble = Graph (sc 1.0 : replicate 14 (sc 0.5))
                   [(0, i, sc 1.0) | i <- [1 .. 14]]

-- ---- 2. a final decided by shootout --------------------------

arabFinal :: Wojak
arabFinal = Wojak
  { wjSeed = CText "arab-club-final-2020"
  , wjCoords =
      [ ("iteration", vec [29.0, 2.0])   -- 29th season, 2nd renamed
      , ("deferral", Ray (sc 2020.0) (sc 2021.64))
      , ("scoreline", Tensor [2, 2] (map sc [4.0, 4.0, 4.0, 3.0]))
      , ("contest", Graph [sc 1.0, sc 1.0] [(0, 1, sc 0.0)])
      , ("stochastic-resolution", sc 0.95)    -- penalties decide it
      , ("codification", sc 0.95)
      , ("embodiment", vec [0.95, 0.2, 0.8])
      , ("venue-occupancy", Ray (sc 53000.0) (sc 0.0))  -- closed doors
      , ("jurisdiction", chain [0.0, 1.0, 2.0, 3.0])
      , ("title-accumulation", sc 2.0)
      , ("record", vec [13.2, 4.0])
      ]
  , wjState = provenance "2020 Arab Club Champions Cup final"
      "https://en.wikipedia.org/wiki/2020_Arab_Club_Champions_Cup_final"
  }

-- ---- 3. a village with three names ---------------------------

nesseby :: Wojak
nesseby = Wojak
  { wjSeed = CText "nesseby-village"
  , wjCoords =
      [ ("terrain", Manifold [([70.1519, 28.865], sc 15.0)])
      , ("hydrology", vec [1.0, 0.0, 0.0])  -- coastal, riverine, inland
      , ("nomination", names [(1.0, 1.0), (1.0, 1.0), (1.0, 0.0)])
      , ("jurisdiction", chain [0.0, 1.0, 2.0, 3.0])
      , ("through-route", routeGraph)          -- E75 passes through
      , ("latitude", sc 70.1519)
      , ("record", vec [3.0, 3.0])
      ]
  , wjState = provenance "Nesseby (village)"
      "https://en.wikipedia.org/wiki/Nesseby_(village)"
  }
 where
  routeGraph = Graph (replicate 3 (sc 1.0))
                     [(0, 1, sc 1.0), (1, 2, sc 1.0)]

-- ---- 4. a comune on the Lombard plain ------------------------

morengo :: Wojak
morengo = Wojak
  { wjSeed = CText "morengo"
  , wjCoords =
      [ ("terrain", Manifold [([45.5333, 9.7], sc 126.0)])
      , ("jurisdiction", chain [0.0, 1.0, 2.0, 3.0])
      , ("latitude", sc 45.5333)
      , ("settlement-density", vec [2537.0, 9.57])   -- people, km^2
      , ("metropolitan-offset", vec [40.0, 20.0])    -- Milan, Bergamo
      , ("nomination", names [(1.0, 1.0)])
      , ("record", vec [2.2, 2.0])
      ]
  , wjState = provenance "Morengo"
      "https://en.wikipedia.org/wiki/Morengo"
  }

-- ---- 5. a seat in the eighth Riigikogu ------------------------

sedasev :: Wojak
sedasev = Wojak
  { wjSeed = CText "igor-sedasev"
  , wjCoords =
      [ ("temporal-extent", Ray (sc 1950.0) (sc 76.0))
      , ("tenure", Ray (sc 8.0) (sc 9.0))    -- VIII Riigikogu, onward
      , ("legitimation", vec [1.0, 0.0, 0.0, 0.0])
      , ("co-occupancy", sc 101.0)           -- seats in the chamber
      , ("record", vec [1.0, 1.0])
      ]
  , wjState = provenance "Igor Sedasev"
      "https://en.wikipedia.org/wiki/Igor_Seda%C5%A1ev"
  }

-- ---- 6. a court painter of flowers ----------------------------

parra :: Wojak
parra = Wojak
  { wjSeed = CText "miguel-parra-abril"
  , wjCoords =
      [ ("temporal-extent", Ray (sc 1780.0) (sc 66.0))
      , ("mimesis", sc 0.9)
      , ("patron-succession", patrons)
      , ("legitimation", vec [0.0, 0.0, 1.0, 0.4])
      , ("stipend", sc 600.0)                    -- ducats per year
      , ("academic-rank", chain [1.0, 2.0, 3.0, 4.0])
      , ("genre-mix", vec [0.6, 0.3, 0.1])  -- floral, portrait, history
      , ("kin-craft", kin)
      , ("record", vec [3.5, 3.0])
      ]
  , wjState = provenance "Miguel Parra Abril"
      "https://en.wikipedia.org/wiki/Miguel_Parra_Abril"
  }
 where
  -- Ferdinand VII -> Maria Christina -> Isabella II
  patrons = Graph (map sc [1.0, 0.8, 0.3])
                  [(0, 1, sc 1.0), (1, 2, sc 1.0)]
  -- brother-in-law and son, both painters
  kin = Graph (replicate 3 (sc 1.0))
              [(0, 1, sc 1.0), (0, 2, sc 1.0)]

-- ---- 7. a body trained five ways ------------------------------

coleman :: Wojak
coleman = Wojak
  { wjSeed = CText "robin-coleman"
  , wjCoords =
      [ ("temporal-extent", Ray (sc 1973.0) (sc 53.0))
      , ("nomination", names [(1.0, 1.0), (1.0, 0.0)])  -- legal, ring
      , ("embodiment", vec [0.95, 0.9, 0.5])
      , ("discipline-repertoire", disciplines)
      , ("placement", results)
      , ("codification", sc 0.7)          -- judged, not adjudicated
      , ("broadcast", vec [1.0, 0.0, 0.0])
      , ("stature", sc 1.854)
      , ("record", vec [4.5, 2.0])
      ]
  , wjState = provenance "Robin Coleman"
      "https://en.wikipedia.org/wiki/Robin_Coleman"
  }
 where
  -- acting, figure, rowing, strongwoman, bodybuilding
  disciplines = Graph (replicate 5 (sc 1.0))
                      [ (4, 3, sc 1.0), (3, 1, sc 0.8)
                      , (4, 1, sc 0.9), (2, 3, sc 0.6)
                      , (0, 3, sc 0.7) ]
  -- year against finishing rank
  results = Matrix [ [sc 1997.0, sc 1.0]
                   , [sc 2001.0, sc 3.0]
                   , [sc 2006.0, sc 11.0] ]

-- rows are designators, columns are (in use, official)
names :: [(Float, Float)] -> Coord
names rows = Matrix [[sc u, sc o] | (u, o) <- rows]

triangleGraph :: Coord
triangleGraph = Graph (replicate 3 (sc 1.0))
                      [(0, 1, sc 1.0), (0, 2, sc 1.0), (1, 2, sc 1.0)]

-- ---- the seven, and how they lie against each other -----------

wikiWojaks :: [Wojak]
wikiWojaks =
  [ theOfficeAu, arabFinal, nesseby, morengo
  , sedasev, parra, coleman ]

wikiSeeds :: [Seed]
wikiSeeds = map wjSeed wikiWojaks

-- Lateral connections. The relation names are the locked 29.
-- These are claims about shape, not about subject matter: none of
-- these pairs shares a domain.
wikiLinks :: [(String, String, String)]
wikiLinks =
  [ ("the-office-au", "igor-sedasev", "Transcendent")
    -- office as room, office as seat; neither contains the other
  , ("the-office-au", "miguel-parra-abril", "Homomorphic")
    -- both are depictions claiming fidelity to an original
  , ("the-office-au", "robin-coleman", "Tangential")
    -- same region of televised performance, no shared node
  , ("the-office-au", "arab-club-final-2020", "Automorphic")
    -- each is an indexed instance of the series it belongs to
  , ("arab-club-final-2020", "robin-coleman", "Homeomorphic")
    -- adjudicated physical contest, stretched not torn
  , ("nesseby-village", "morengo", "Isomorphic")
    -- a settlement inside nested jurisdictions, relabelled
  , ("nesseby-village", "igor-sedasev", "Collateral")
    -- official tongue meeting a minority register, distant kin
  , ("igor-sedasev", "miguel-parra-abril", "Antipodal")
    -- elected against appointed on the legitimation axis
  , ("miguel-parra-abril", "robin-coleman", "Inverse")
    -- the body as depicted subject against the body as instrument
  ]

-- ---- grafting -------------------------------------------------

-- Idempotent: seeds already present accrete rather than duplicate,
-- and a link that already exists is not laid twice.
graftWikiSeeds :: Field -> Field
graftWikiSeeds f0 = foldl link (foldl grow f0 wikiWojaks) wikiLinks
 where
  grow f w = addWojak w f
  link f (a, b, rel)
    | any (joins (CText a) (CText b)) (fConns f) = f
    | otherwise = connect (CText a) (CText b)
                    (cmap [("relation", CText rel)]) f
  joins x y c = (cnA c == x && cnB c == y)
                || (cnA c == y && cnB c == x)
