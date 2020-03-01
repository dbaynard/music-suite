{-# OPTIONS_GHC -Wall
  -Wcompat
  -Wincomplete-record-updates
  -Wincomplete-uni-patterns
  -Werror
  -fno-warn-name-shadowing
  -fno-warn-unused-imports
  -fno-warn-redundant-constraints #-}

module Music.Time.Reverse
  ( module Music.Time.Position,

    -- * The Reversible class
    Reversible (..),

    -- * Reversing
    reversed,
    revDefault,

    -- * Utility
    NoReverse (..),
  )
where

import Control.Lens hiding
  ( (<|),
    Indexable,
    Level,
    below,
    index,
    inside,
    parts,
    reversed,
    transform,
    (|>),
  )
import Data.AffineSpace
import Data.AffineSpace
import Data.AffineSpace.Point
import Data.AffineSpace.Point
import Data.Functor.Couple
import Data.Map (Map)
import Data.Map (Map)
import qualified Data.Map as Map
import qualified Data.Map as Map
import Data.Ratio
import Data.Semigroup
import Data.Semigroup hiding ()
import Data.Sequence (Seq)
import qualified Data.Sequence as Seq
import Data.Set (Set)
import qualified Data.Set as Set
import Data.Typeable
import Data.VectorSpace
import Data.VectorSpace hiding (Sum (..))
import Music.Time.Position

-- |
-- Class of values that can be reversed (retrograded).
--
-- For positioned values succh as 'Note', the value is reversed relative to its middle point, i.e.
-- the onset value becomes the offset value and vice versa.
--
-- For non-positioned values such as 'Stretched', the value is reversed in-place.
--
-- FIXME Second law is incompatible with 'revDefault' (and the 'Span' definition below)
--
-- Law
--
-- @
-- 'rev' ('rev' a) = a
-- @
--
-- @
-- 'abs' (x^.'duration') = ('rev' x)^.'duration'
-- @
--
-- @
-- 'rev' s `transform` a = 'rev' (s `transform` a)
-- @
--
-- or equivalently,
--
-- @
-- 'transform' . 'rev' = 'fmap' 'rev' . 'transform'
-- @
--
-- For 'Span'
--
-- @
-- 'rev' = 'over' 'onsetAndOffset' 'swap'
-- @
class Transformable a => Reversible a where
  -- | Reverse (retrograde) the given value.
  rev :: a -> a

--
-- XXX Counter-intuitive Behavior instances (just Behavior should reverse around origin,
-- while Bound (Behavior a) should reverse around the middle, like a note)
--

--
-- XXX Alternate formulation of second Reversiblee law
--
--     rev s `transform` a     = rev (s `transform` a)
-- ==> (rev s `transform`)     = rev . (s `transform`)
-- ==> transform (rev s)       = rev . (transform s)
-- ==> (transform . rev) s     = (rev .) (transform s)
-- ==> (transform . rev) s     = fmap rev (transform s)
-- ==> transform . rev         = fmap rev . transform
--

instance Reversible () where
  rev = id

instance Reversible Int where
  rev = id

instance Reversible Double where
  rev = id

instance Reversible Integer where
  rev = id

instance Reversible Char where
  rev = id

instance Reversible a => Reversible (Maybe a) where
  rev = fmap rev

instance Reversible a => Reversible [a] where
  rev = reverse . fmap rev

instance Reversible a => Reversible (Seq a) where
  rev = Seq.reverse . fmap rev

instance (Ord k, Reversible a) => Reversible (Map k a) where
  rev = Map.map rev

instance Reversible Duration where
  rev = stretch (-1)

--
-- There is no instance for Reversible Time
-- as we can not satisfy the second Reversible law
--

instance Reversible Span where
  rev = revDefault

instance Reversible a => Reversible (b, a) where
  rev (s, a) = (s, rev a)

deriving instance (Monoid b, Reversible a) => Reversible (Couple b a)

-- |
-- A default implementation of 'rev'
revDefault :: (HasPosition a, Transformable a) => a -> a
revDefault x = stretch (-1) x

-- Alternative:
-- revDefault x = (stretch (-1) `whilst` undelaying (_position x 0.5 .-. 0)) x
--   where f `whilst` t = over (transformed t) f

newtype NoReverse a = NoReverse {getNoReverse :: a}
  deriving (Typeable, Eq, Ord, Show)

instance Transformable (NoReverse a) where
  transform _ = id

instance Reversible (NoReverse a) where
  rev = id

-- |
-- View the reverse of a value.
--
-- >>> [1,2,3] & reversed %~ Data.List.sort
-- [3,2,1]
reversed :: Reversible a => Iso' a a
reversed = iso rev rev
