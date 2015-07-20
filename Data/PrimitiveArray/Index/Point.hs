
-- | @Point@ index structures are used for left- and right-linear grammars.
-- Such grammars have at most one syntactic symbol on each r.h.s. of a rule.
-- The syntactic symbol needs to be in an outermost position.

module Data.PrimitiveArray.Index.Point where

import           Control.Applicative
import           Control.DeepSeq (NFData(..))
import           Data.Aeson
import           Data.Binary
import           Data.Bits
import           Data.Bits.Extras (Ranked)
import           Data.Hashable (Hashable)
import           Data.Serialize
import           Data.Vector.Fusion.Stream.Size
import           Data.Vector.Unboxed.Deriving
import           Data.Vector.Unboxed (Unbox(..))
import           GHC.Generics
import qualified Data.Vector.Fusion.Stream.Monadic as SM
import qualified Data.Vector.Unboxed as VU
import           Test.QuickCheck

import           Data.PrimitiveArray.Index.Class



-- | A point in a left-linear grammar. The syntactic symbol is in left-most
-- position.

newtype PointL = PointL {fromPointL :: Int}
  deriving (Eq,Read,Show,Generic)

-- | A point in a right-linear grammars.

newtype PointR = PointR {fromPointR :: Int}
  deriving (Eq,Read,Show,Generic)



derivingUnbox "PointL"
  [t| PointL -> Int    |]
  [| \ (PointL i) -> i |]
  [| \ i -> PointL i   |]

instance Binary    PointL
instance Serialize PointL
instance FromJSON  PointL
instance ToJSON    PointL
instance Hashable  PointL

instance NFData PointL where
  rnf (PointL l) = rnf l
  {-# Inline rnf #-}

instance Index PointL where
  linearIndex _ _ (PointL z) = z
  {-# INLINE linearIndex #-}
  smallestLinearIndex (PointL l) = error "still needed?"
  {-# INLINE smallestLinearIndex #-}
  largestLinearIndex (PointL h) = h
  {-# INLINE largestLinearIndex #-}
  size (_) (PointL h) = h + 1
  {-# INLINE size #-}
  inBounds (_) (PointL h) (PointL x) = 0<=x && x<=h
  {-# INLINE inBounds #-}

instance IndexStream z => IndexStream (z:.PointL) where
  streamUp (ls:.PointL lf) (hs:.PointL ht) = SM.flatten mk step Unknown $ streamUp ls hs
    where mk z = return (z,lf)
          step (z,k)
            | k > ht    = return $ SM.Done
            | otherwise = return $ SM.Yield (z:.PointL k) (z,k+1)
          {-# Inline [0] mk   #-}
          {-# Inline [0] step #-}
  {-# Inline streamUp #-}
  streamDown (ls:.PointL lf) (hs:.PointL ht) = SM.flatten mk step Unknown $ streamDown ls hs
    where mk z = return (z,ht)
          step (z,k)
            | k < lf    = return $ SM.Done
            | otherwise = return $ SM.Yield (z:.PointL k) (z,k-1)
          {-# Inline [0] mk   #-}
          {-# Inline [0] step #-}
  {-# Inline streamDown #-}

instance IndexStream PointL

instance Arbitrary PointL where
  arbitrary = do
    b <- choose (0,100)
    return $ PointL b
  shrink (PointL j)
    | 0<j = [PointL $ j-1]
    | otherwise = []



derivingUnbox "PointR"
  [t| PointR -> Int    |]
  [| \ (PointR i) -> i |]
  [| \ i -> PointR i   |]

instance Binary    PointR
instance Serialize PointR
instance FromJSON  PointR
instance ToJSON    PointR

instance NFData PointR where
  rnf (PointR l) = rnf l
  {-# Inline rnf #-}

instance Index PointR where
  linearIndex l _ (PointR z) = undefined
  {-# INLINE linearIndex #-}
  smallestLinearIndex = undefined
  {-# INLINE smallestLinearIndex #-}
  largestLinearIndex = undefined
  {-# INLINE largestLinearIndex #-}
  size = undefined
  {-# INLINE size #-}

