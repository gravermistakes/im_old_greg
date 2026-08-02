-- Seed authored 2026-07-26 from an Immunefi engagement across Sky, Enzyme
-- and Gnosis Chain. Forty leads died; two of them died the same way.
-- Two instances, same codebase, six months apart, is not a coincidence.
-- It is a shape.
module Seeds.LatchGuard ( latchGuard, instances, edges ) where

import Wojak

-- ---- the seed ------------------------------------------------
-- The irreducible kernel: a guard that answers WHEN instead of WHO.
-- Everything else about an instance may change. This does not.

latchGuard :: Seed
latchGuard = "a privileged mutation whose only gate is that it already happened"

-- ---- axes the content itself takes ---------------------------
-- Not handed out. Taken. Five, because five is what the shape occupies.

-- Guard Modality: temporal (0.0) .. identity (1.0)
--   A run-once boolean sits at 0. `require(msg.sender == x)` sits at 1.
--   Both instances sit at 0 while behaving, in the post-execution window,
--   exactly as if they sat at 1. That impersonation is the whole defect.
guardModality :: Coord
guardModality = Scalar 0.0

-- Reachability Window: directional, irreversible. Ray is the correct type.
--   origin = deployment (open), destination = execution (closed forever).
--   Every instance of this shape is Critical inside the ray and dead after.
reachWindow :: Coord
reachWindow = Ray (Scalar 1.0) (Scalar 0.0)

-- Artifact Divergence: deployed-vs-reviewed, per instance.
artifactDivergence :: Coord
artifactDivergence = Vector [Scalar 1.0, Scalar 0.0]

-- Blast Radius: log10 USD reachable from inside the window.
blastRadius :: Coord
blastRadius = Vector [Scalar 6.4, Scalar 7.85]

-- Latch State: the single bit separating "informational" from "$2M".
latchState :: Coord
latchState = Vector [Scalar 1.0, Scalar 1.0]

-- ---- observed instances --------------------------------------

instances :: [(String, Coord)]
instances =
  [ -- Gnosis ForeignOmnibridge.migrateTo_3_3_0, Ethereum.
    -- require(msg.sender == address(this)) present in repo AND on the
    -- Home-side twin; DELETED in deployed code. Body performs
    -- _setTokenFactory(caller-supplied) and
    -- safeTransfer(caller-supplied, balance - 2.5M) for USDC and USDT.
    -- Latch slot 0x612ef5ed..869a reads 1. Dead by one transaction.
    ( "gnosis/migrateTo_3_3_0"
    , Vector [ Scalar 0.0, Ray (Scalar 1.0) (Scalar 0.0)
             , Scalar 1.0, Scalar 6.4, Scalar 1.0 ] )

    -- Gnosis XDaiForeignBridge.swapSDAIToUSDS(), Ethereum, $70.7M contract.
    -- public, zero access control. Guard is boolStorage[
    -- keccak256("upgrade_DAI_to_USDS")]. Slot 0x5b44e1cf..ce79 reads 1.
    -- Deployed matches repo exactly -- so this instance is NOT drift.
    -- The shape survives without drift. That is the important part.
  , ( "gnosis/swapSDAIToUSDS"
    , Vector [ Scalar 0.0, Ray (Scalar 1.0) (Scalar 0.0)
             , Scalar 0.0, Scalar 7.85, Scalar 1.0 ] )
  ]

-- ---- relationships -------------------------------------------

edges :: [(String, String, String)]
edges =
  [ -- The core operation. Different names, different contracts, different
    -- authors, six months apart, identical structure.
    ("gnosis/migrateTo_3_3_0", "gnosis/swapSDAIToUSDS", "Isomorphic")

    -- Drift without the latch shape. Structure-preserving, not bijective.
  , ("enzyme/ThreeOneThirdAdapter", latchGuard, "Homomorphic")

    -- The cross-domain payoff, and the reason this belongs in the field
    -- rather than in a bug tracker: a check-then-act race in a filesystem
    -- is this same shape with different labels. Transcendent -- you have
    -- to leave both to see it.
  , ("posix/TOCTOU-open-then-chmod", latchGuard, "Isomorphic")

    -- Both live on Guard Modality. Actively opposite on it. Not unrelated.
  , ("solidity/onlyOwner", latchGuard, "Antipodal")
  ]
