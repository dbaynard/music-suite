{-# OPTIONS_GHC
  -Wall
  -Wcompat
  -Wincomplete-record-updates
  -Wincomplete-uni-patterns
  -Werror
  -fno-warn-name-shadowing
  -fno-warn-unused-matches
  -fno-warn-unused-imports
  #-}
-- | Provides colored note heads.
module Music.Score.Color
  ( -- ** HasColor class
    HasColor (..),

    -- * Manipulating color
    color,
    colorRed,
    colorBlue,
    colorBlack,

    -- * Representation
    ColorT (..),
    runColorT,
  )
where

import Control.Applicative
import Control.Comonad
import Control.Lens hiding (below, transform)
import Data.AffineSpace
import Data.Colour
import qualified Data.Colour.Names as C
import Data.Foldable
import Data.Functor.Couple
import Data.Semigroup
import Data.Typeable
import Music.Dynamics.Literal
import Music.Pitch.Alterable
import Music.Pitch.Augmentable
import Music.Pitch.Literal
import Music.Score.Harmonics
import Music.Score.Part
import Music.Score.Part
import Music.Score.Phrases
import Music.Score.Slide
import Music.Score.Text
import Music.Score.Ties
import Music.Score.Tremolo
import Music.Time
import Music.Time.Internal.Transform

class HasColor a where
  setColor :: Colour Double -> a -> a

instance HasColor a => HasColor (b, a) where
  setColor s = fmap (setColor s)

deriving instance HasColor a => HasColor (Couple b a)

instance HasColor a => HasColor [a] where
  setColor s = fmap (setColor s)

instance HasColor a => HasColor (Score a) where
  setColor s = fmap (setColor s)

instance HasColor a => HasColor (Voice a) where
  setColor s = fmap (setColor s)

instance HasColor a => HasColor (Note a) where
  setColor s = fmap (setColor s)

instance HasColor a => HasColor (PartT n a) where
  setColor s = fmap (setColor s)

instance HasColor a => HasColor (TieT a) where
  setColor s = fmap (setColor s)

newtype ColorT a = ColorT {getColorT :: Couple (Option (Last (Colour Double))) a}
  deriving (Eq {-Ord,-}, Show, Functor, Foldable {-Typeable,-}, Applicative, Monad, Comonad)

runColorT :: ColorT a -> (Colour Double, a)
runColorT (ColorT (Couple (_, a))) = (error "TODO color export", a)

-- Lifted instances
deriving instance Num a => Num (ColorT a)

deriving instance Fractional a => Fractional (ColorT a)

deriving instance Floating a => Floating (ColorT a)

deriving instance Enum a => Enum (ColorT a)

deriving instance Bounded a => Bounded (ColorT a)

instance Wrapped (ColorT a) where

  type Unwrapped (ColorT a) = Couple (Option (Last (Colour Double))) a

  _Wrapped' = iso getColorT ColorT

instance Rewrapped (ColorT a) (ColorT b)

instance HasColor (ColorT a) where
  setColor s (ColorT (Couple (t, x))) = ColorT $ Couple (t <> wrap s, x)
    where
      wrap = Option . Just . Last

instance Semigroup a => Semigroup (ColorT a) where
  (<>) = liftA2 (<>)

instance Tiable a => Tiable (ColorT a) where
  toTied (ColorT (Couple (n, a))) = (ColorT $ Couple (n, b), ColorT $ Couple (n, c))
    where
      (b, c) = toTied a

-- |
-- Set color of all notes in the score.
color :: HasColor a => Colour Double -> a -> a
color = setColor

-- |
-- Color all notes in the score red.
colorRed :: HasColor a => a -> a
colorRed = color C.red

-- |
-- Color all notes in the score blue.
colorBlue :: HasColor a => a -> a
colorBlue = color C.blue

-- |
-- Color all notes in the score black.
colorBlack :: HasColor a => a -> a
colorBlack = color C.black
