-- | Provides a representation of musical /slides/, commonly known as /glissando/ or
-- /portamento/.
module Music.Score.Slide
  ( -- * Slides and glissando
    HasSlide (..),
    SlideT (..),
    runSlideT,
    slide,
    glissando,
  )
where

import Control.Applicative
import Control.Comonad
import Control.Lens hiding (transform)
import Data.Foldable
import Data.Foldable
import Data.Functor.Couple
import Data.Ratio
import Data.Semigroup
import Data.Typeable
import Data.Word
import Music.Dynamics.Literal
import Music.Pitch.Alterable
import Music.Pitch.Augmentable
import Music.Pitch.Literal
import Music.Score.Part
import Music.Score.Phrases
import Music.Time.Note
import Music.Time.Voice
import Music.Time.Score

class HasSlide a where

  setBeginGliss :: Bool -> a -> a

  setBeginSlide :: Bool -> a -> a

  setEndGliss :: Bool -> a -> a

  setEndSlide :: Bool -> a -> a

instance HasSlide a => HasSlide (b, a) where

  setBeginGliss n = fmap (setBeginGliss n)

  setBeginSlide n = fmap (setBeginSlide n)

  setEndGliss n = fmap (setEndGliss n)

  setEndSlide n = fmap (setEndSlide n)

instance HasSlide a => HasSlide (Couple b a) where

  setBeginGliss n = fmap (setBeginGliss n)

  setBeginSlide n = fmap (setBeginSlide n)

  setEndGliss n = fmap (setEndGliss n)

  setEndSlide n = fmap (setEndSlide n)

instance HasSlide a => HasSlide [a] where

  setBeginGliss n = fmap (setBeginGliss n)

  setBeginSlide n = fmap (setBeginSlide n)

  setEndGliss n = fmap (setEndGliss n)

  setEndSlide n = fmap (setEndSlide n)

instance HasSlide a => HasSlide (Score a) where

  setBeginGliss n = fmap (setBeginGliss n)

  setBeginSlide n = fmap (setBeginSlide n)

  setEndGliss n = fmap (setEndGliss n)

  setEndSlide n = fmap (setEndSlide n)

instance HasSlide a => HasSlide (Voice a) where

  setBeginGliss n = fmap (setBeginGliss n)

  setBeginSlide n = fmap (setBeginSlide n)

  setEndGliss n = fmap (setEndGliss n)

  setEndSlide n = fmap (setEndSlide n)

instance HasSlide a => HasSlide (Note a) where

  setBeginGliss n = fmap (setBeginGliss n)

  setBeginSlide n = fmap (setBeginSlide n)

  setEndGliss n = fmap (setEndGliss n)

  setEndSlide n = fmap (setEndSlide n)

-- (eg,es,a,bg,bs)
newtype SlideT a = SlideT {getSlideT :: Couple ((Any, Any), (Any, Any)) a}
  deriving (Eq, Show, Ord, Functor, Foldable, Typeable, Applicative, Monad, Comonad)

-- TODO export type other than () - see ColorT et al.
runSlideT :: SlideT a -> ((), a)
runSlideT (SlideT (Couple (_, x))) = ((), x)

instance Wrapped (SlideT a) where

  type Unwrapped (SlideT a) = Couple ((Any, Any), (Any, Any)) a

  _Wrapped' = iso getSlideT SlideT

instance Rewrapped (SlideT a) (SlideT b)

_bg, _bs, _eg, _es :: Lens' (SlideT a) Any
_bg = (_Wrapped' . _Wrapped') . _1 . _2 . _1
_bs = (_Wrapped' . _Wrapped') . _1 . _2 . _2
_eg = (_Wrapped' . _Wrapped') . _1 . _1 . _1
_es = (_Wrapped' . _Wrapped') . _1 . _1 . _2

instance HasSlide (SlideT a) where

  setBeginGliss x = _bg .~ Any x

  setBeginSlide x = _bs .~ Any x

  setEndGliss x = _eg .~ Any x

  setEndSlide x = _es .~ Any x

-- Lifted instances
deriving instance Num a => Num (SlideT a)

deriving instance Fractional a => Fractional (SlideT a)

deriving instance Floating a => Floating (SlideT a)

deriving instance Enum a => Enum (SlideT a)

deriving instance Bounded a => Bounded (SlideT a)

deriving instance (Num a, Ord a, Real a) => Real (SlideT a)

deriving instance (Real a, Enum a, Integral a) => Integral (SlideT a)

-- |
-- Add a slide between the first and the last note.
slide :: (HasPhrases' s a, HasSlide a) => s -> s
slide = mapPhraseWise3 (setBeginSlide True) (setBeginSlide True . setEndSlide True) (setEndSlide True)
  where
    mapPhraseWise3 f g h = over phrases' (over _head f . over (_tail . _init) g . over _last h)

-- |
-- Add a glissando between the first and the last note.
glissando :: (HasPhrases' s a, HasSlide a) => s -> s
glissando = mapPhraseWise3 (setBeginGliss True) (setBeginGliss True . setEndGliss True) (setEndGliss True)
  where
    mapPhraseWise3 f g h = over phrases' (over _head f . over (_tail . _init) g . over _last h)
