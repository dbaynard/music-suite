
{-# LANGUAGE FlexibleContexts #-}

module Music.Time.Score (
        -- * Score type
        Score,

        -- * Query

        -- * Construction
        score,
        events,
        eras,
        triples,

        -- * Traversal
        mapWithSpan,
        filterWithSpan,
        mapFilterWithSpan,
        mapTriples,
        filterTriples,
        mapFilterTriples,

        -- * Simultaneous
        -- TODO check for overlapping values etc
        -- simult,
        hasOverlappingEvents,
        simultaneous,

        -- * Normalize
        normalizeScore,
        removeRests,

        -- * Utility
        printEras,

        -- * Unsafe versions
        eventsIgnoringMeta,
        triplesIgnoringMeta,

  ) where

import           Control.Applicative
import           Control.Comonad
import           Control.Lens             hiding (Indexable, Level, above,
                                           below, index, inside, parts,
                                           reversed, transform, (<|), (|>))
import           Control.Monad
import           Control.Monad.Compose
import           Control.Monad.Plus
import           Data.AffineSpace
import           Data.AffineSpace.Point
import           Data.Foldable            (Foldable)
import qualified Data.Foldable            as Foldable
import           Data.Functor.Adjunction  (unzipR)
import qualified Data.List                as List
import qualified Data.List.NonEmpty       as NonEmpty
import           Data.Map                 (Map)
import qualified Data.Map                 as Map
import qualified Data.Ord                 as Ord
import           Data.Ratio
import           Data.Semigroup
import           Data.Semigroup           hiding ()
import           Data.Set                 (Set)
import qualified Data.Set                 as Set
import           Data.String
import           Data.Traversable         (Traversable)
import qualified Data.Traversable         as T
import           Data.Typeable
import           Data.VectorSpace
import           Data.VectorSpace         hiding (Sum (..))
import           Data.Aeson                    (ToJSON (..), FromJSON(..))
import qualified Data.Aeson                    as JSON

import           Music.Dynamics.Literal
import           Music.Pitch.Literal
import           Music.Time.Event
import           Music.Time.Internal.Util
import           Music.Time.Juxtapose
import           Music.Time.Meta
import           Music.Time.Note
import           Music.Time.Voice



--   * 'empty' creates an empty score
--
--   * 'pure' creates a score containing a single note in the span @0 '<->' 1@
--
--   * '<|>' composes scores in parallel
--
--   * '|>' composes scores as a forward sequence
--
--   * '<|' composes scores as a backward sequence
--
-- You can also use '<>' and 'mempty' of course.
--

-- | A 'Score' is a sequential or parallel composition of values, and allows overlapping events
newtype Score a = Score { getScore :: (Meta, Score' a) }
    deriving (Functor, Semigroup, Monoid, Foldable, Traversable, Typeable{-, Show, Eq, Ord-})

--
-- You typically create a 'Score' using 'score', 'events', 'voices', and 'phrases', or the 'Alternative' interface.
--
-- Score is an instance of 'Transformable', so you can use 'delay' and 'stretch'.
--
-- Score is an instance of 'HasPosition', so you can use 'duration', 'onset', 'offset', 'era'.
--
-- To inspect or deconstruct a score, see 'events', 'voices', and 'phrases', as
-- well as 'singleNote', 'singleVoice', and 'singlePhrase'
--

instance Wrapped (Score a) where
  type Unwrapped (Score a) = (Meta, Score' a)
  _Wrapped' = iso getScore Score

instance Rewrapped (Score a) (Score b) where

instance Applicative Score where
  pure = return
  (<*>) = ap

instance Monad Score where
  return = (^. _Unwrapped') . return . return
  xs >>= f = (^. _Unwrapped') $ mbind ((^. _Wrapped') . f) ((^. _Wrapped') xs)

instance Alternative Score where
  empty = mempty
  (<|>) = mappend

instance MonadPlus Score where
  mzero = mempty
  mplus = mappend

{-
instance FunctorWithIndex Span Score where
  imap f = over (_Wrapped._2) $ imap f

instance FoldableWithIndex Span Score where
  ifoldMap f (Score (m,x)) = ifoldMap f x

instance TraversableWithIndex Span Score where
  itraverse f (Score (m,x)) = fmap (\x -> Score (m,x)) $ itraverse f x
-}

instance ToJSON a => ToJSON (Score a) where
  -- TODO meta
  toJSON x = JSON.object [ ("events", toJSON es) ]
    where
      es = x^.events

instance FromJSON a => FromJSON (Score a) where
  -- TODO change to include meta
  parseJSON (JSON.Object x) = parseEL =<< (x JSON..: "events")
    where
      parseEL (JSON.Array xs) = fmap ((^.score) . toList) $ traverse parseJSON xs
      toList = toListOf traverse
  parseJSON _ = empty

instance Transformable (Score a) where
  transform t (Score (m,x)) = Score (transform t m, transform t x)

-- instance Reversible a => Reversible (Score a) where
  -- rev (Score (m,x)) = Score (rev m, rev x)

-- instance Splittable a => Splittable (Score a) where
  -- split t (Score (m,x)) = (Score (m1,x1), Score (m2,x2))
    -- where
      -- (m1, m2) = split t m
      -- (x1, x2) = split t x

-- TODO move these two "implementations" to Score'
instance HasPosition (Score a) where
  _position = _position . snd . view _Wrapped' {-. normalizeScore'-}
  -- TODO clean up in terms of AddMeta and optimize

instance HasDuration (Score a) where
  _duration x = (^.offset) x .-. (^.onset) x



-- Lifted instances

instance IsString a => IsString (Score a) where
  fromString = pure . fromString

instance IsPitch a => IsPitch (Score a) where
  fromPitch = pure . fromPitch

instance IsInterval a => IsInterval (Score a) where
  fromInterval = pure . fromInterval

instance IsDynamics a => IsDynamics (Score a) where
  fromDynamics = pure . fromDynamics

-- Bogus instance, so we can use [c..g] expressions
instance Enum a => Enum (Score a) where
  toEnum = return . toEnum
  fromEnum = list 0 (fromEnum . head) . Foldable.toList

instance Num a => Num (Score a) where
  fromInteger = return . fromInteger
  abs    = fmap abs
  signum = fmap signum
  (+)    = liftA2 (+)
  (-)    = liftA2 (-)
  (*)    = liftA2 (*)

{-
-- Bogus instances, so we can use c^*2 etc.
instance AdditiveGroup (Score a) where
  zeroV   = error "Not implemented"
  (^+^)   = error "Not implemented"
  negateV = error "Not implemented"

instance VectorSpace (Score a) where
  type Scalar (Score a) = Duration
  d *^ s = d `stretch` s
-}

instance HasMeta (Score a) where
  meta = _Wrapped . _1







newtype Score' a = Score' { getScore' :: [Event a] }
  deriving ({-Eq, -}{-Ord, -}{-Show, -}Functor, Foldable, Traversable, Semigroup, Monoid, Typeable, Show, Eq)

instance (Show a, Transformable a) => Show (Score a) where
  show x = show (x^.events) ++ "^.score"

instance Wrapped (Score' a) where
  type Unwrapped (Score' a) = [Event a]
  _Wrapped' = iso getScore' Score'

instance Rewrapped (Score' a) (Score' b)

instance Applicative Score' where
  pure  = return
  (<*>) = ap

instance Monad Score' where
  return = (^. _Unwrapped) . pure . pure
  xs >>= f = (^. _Unwrapped) $ mbind ((^. _Wrapped') . f) ((^. _Wrapped') xs)

instance Alternative Score' where
  empty = mempty
  (<|>) = mappend

instance MonadPlus Score' where
  mzero = mempty
  mplus = mappend

instance Transformable (Score' a) where
  transform t = over (_Wrapped) (transform t)

-- instance Reversible a => Reversible (Score' a) where
--   rev (Score' xs) = Score' (fmap rev xs)

instance HasPosition (Score' a) where
  _era x = (f x, g x)^.from onsetAndOffset
    where
      f = safeMinimum . fmap ((^.onset)  . normalizeSpan) . toListOf (_Wrapped . each . era)
      g = safeMaximum . fmap ((^.offset) . normalizeSpan) . toListOf (_Wrapped . each . era)
      safeMinimum xs = if null xs then 0 else minimum xs
      safeMaximum xs = if null xs then 0 else maximum xs

instance HasDuration (Score' a) where
  _duration x = (^.offset) x .-. (^.onset) x

-- | Create a score from a list of events.
score :: Getter [Event a] (Score a)
score = from eventsIgnoringMeta
{-# INLINE score #-}

-- | View a 'Score' as a list of 'Event' values.
events :: Lens (Score a) (Score b) [Event a] [Event b]
events = _Wrapped . _2 . _Wrapped . sorted
  where
    -- TODO should not have to sort...
    sorted = iso (List.sortBy (Ord.comparing (^.onset))) (List.sortBy (Ord.comparing (^.onset)))
{-# INLINE events #-}

--
-- @
-- 'view' 'events'                        :: 'Score' a -> ['Event' a]
-- 'set'  'events'                        :: ['Event' a] -> 'Score' a -> 'Score' a
-- 'over' 'events'                        :: (['Event' a] -> ['Event' b]) -> 'Score' a -> 'Score' b
-- @
--
-- @
-- 'preview'  ('events' . 'each')           :: 'Score' a -> 'Maybe' ('Event' a)
-- 'preview'  ('events' . 'element' 1)      :: 'Score' a -> 'Maybe' ('Event' a)
-- 'preview'  ('events' . 'elements' odd)   :: 'Score' a -> 'Maybe' ('Event' a)
-- @
--
-- @
-- 'set'      ('events' . 'each')           :: 'Event' a -> 'Score' a -> 'Score' a
-- 'set'      ('events' . 'element' 1)      :: 'Event' a -> 'Score' a -> 'Score' a
-- 'set'      ('events' . 'elements' odd)   :: 'Event' a -> 'Score' a -> 'Score' a
-- @
--
-- @
-- 'over'     ('events' . 'each')           :: ('Event' a -> 'Event' b) -> 'Score' a -> 'Score' b
-- 'over'     ('events' . 'element' 1)      :: ('Event' a -> 'Event' a) -> 'Score' a -> 'Score' a
-- 'over'     ('events' . 'elements' odd)   :: ('Event' a -> 'Event' a) -> 'Score' a -> 'Score' a
-- @
--
-- @
-- 'toListOf' ('events' . 'each')                :: 'Score' a -> ['Event' a]
-- 'toListOf' ('events' . 'elements' odd)        :: 'Score' a -> ['Event' a]
-- 'toListOf' ('events' . 'each' . 'filtered'
--              (\\x -> x^.'duration' \< 2))  :: 'Score' a -> ['Event' a]
-- @

-- | A score is a list of events up to meta-data. To preserve meta-data, use the more
-- restricted 'score' and 'events'.
eventsIgnoringMeta :: Iso (Score a) (Score b) [Event a] [Event b]
eventsIgnoringMeta = _Wrapped . noMeta . _Wrapped . sorted
  where
    sorted = iso (List.sortBy (Ord.comparing (^.onset))) (List.sortBy (Ord.comparing (^.onset)))
    noMeta = iso extract return

-- | A score is a list of (time-duration-value triples) up to meta-data.
-- To preserve meta-data, use the more restricted 'triples'.
triplesIgnoringMeta :: Iso (Score a) (Score b) [(Time, Duration, a)] [(Time, Duration, b)]
triplesIgnoringMeta = iso _getScore _score
  where
    _score :: [(Time, Duration, a)] -> Score a
    _score = mconcat . fmap (uncurry3 event)
      where
        event t d x   = (delay (t .-. 0) . stretch d) (return x)

    _getScore :: {-Transformable a => -}Score a -> [(Time, Duration, a)]
    _getScore =
      fmap (\(view onsetAndDuration -> (t,d),x) -> (t,d,x)) .
      List.sortBy (Ord.comparing fst) .
      Foldable.toList .
      fmap (view $ from event) .
      reifyScore

-- | Map with the associated time span.
mapScore :: (Event a -> b) -> Score a -> Score b
mapScore f = over (_Wrapped._2) (mapScore' f)
  where
    mapScore' f = over (_Wrapped.traverse) (extend f)

reifyScore :: Score a -> Score (Event a)
reifyScore = over (_Wrapped . _2 . _Wrapped) $ fmap duplicate

-- | View a score as a list of time-duration-value triplets.
triples :: {-Transformable a => -}Lens (Score a) (Score b) [(Time, Duration, a)] [(Time, Duration, b)]
triples = triplesIgnoringMeta


-- | Map over the values in a score.
mapWithSpan :: (Span -> a -> b) -> Score a -> Score b
mapWithSpan f = mapScore (uncurry f . view (from event))

-- | Filter the values in a score.
filterWithSpan :: (Span -> a -> Bool) -> Score a -> Score a
filterWithSpan f = mapFilterWithSpan (partial2 f)

-- | Combination of 'mapTriples' and 'filterTriples'.
mapFilterWithSpan :: (Span -> a -> Maybe b) -> Score a -> Score b
mapFilterWithSpan f = mcatMaybes . mapWithSpan f

-- | Map over the values in a score.
mapTriples :: (Time -> Duration -> a -> b) -> Score a -> Score b
mapTriples f = mapWithSpan (uncurry f . view onsetAndDuration)

-- | Filter the values in a score.
filterTriples   :: (Time -> Duration -> a -> Bool) -> Score a -> Score a
filterTriples f = mapFilterTriples (partial3 f)

-- | Efficient combination of 'mapTriples' and 'filterTriples'.
mapFilterTriples :: (Time -> Duration -> a -> Maybe b) -> Score a -> Score b
mapFilterTriples f = mcatMaybes . mapTriples f

-- | Normalize a score, assuring its events spans are all forward (as by 'isForwardSpan'),
-- and that its onset is at least zero. Consequently, the onset and offset of each event
-- in the score is at least zero.
normalizeScore :: Score a -> Score a
normalizeScore = reset . normalizeScoreDurations
  where
    reset x = set onset (view onset x `max` 0) x
    normalizeScoreDurations = over (events . each . era) normalizeSpan

removeRests :: Score (Maybe a) -> Score a
removeRests = mcatMaybes

-- TODO version that reverses the values where appropriate
-- Use over (events . each) normalizeEvent or similar

-- |
-- Print the span of each event, as given by 'eras'.
--
printEras :: Score a -> IO ()
printEras = mapM_ print . toListOf eras

-- |
-- Print all eras of the given score.
--
-- >>> toListOf eras $ scat [c,d,e :: Score Integer]
-- [0 <-> 1,1 <-> 2,2 <-> 3]
--
eras :: Traversal' (Score a) Span
eras = events . each . era

-- TODO rename and expose this
-- We have an (Iso (Score a) (TMap Span [a])), with [] as default value
chordEvents :: Transformable a => Span -> Score a -> [a]
chordEvents s = fmap extract . filter ((== s) . view era) . view events

simultaneous' :: Transformable a => Score a -> Score [a]
simultaneous' sc = (^. from triplesIgnoringMeta) vs
  where
    -- es :: [Era]
    -- evs :: [[a]]
    -- vs :: [(Time, Duration, [a])]
    es  = List.nub $ toListOf eras sc
    evs = fmap (`chordEvents` sc) es
    vs  = zipWith (\(view onsetAndDuration -> (t,d)) a -> (t,d,a)) es evs

-- overSimult :: Transformable a => (Score [a] -> Score [b]) -> Score a -> Score b
-- overSimult f = mscatter . f . simultaneous'

-- | Merge all simultaneous events using their 'Semigroup' instance.
simultaneous :: (Transformable a, Semigroup a) => Score a -> Score a
simultaneous = fmap (sconcat . NonEmpty.fromList) . simultaneous'



hasOverlappingEvents :: Score a -> Bool
hasOverlappingEvents = anyDistinctOverlaps . toListOf (events.each.era)

hasDuplicates :: Eq a => [a] -> Bool
hasDuplicates xs = List.nub xs /= xs

anyDistinctOverlaps :: [Span] -> Bool
anyDistinctOverlaps xs = hasDuplicates xs || anyOverlaps xs
  where
    anyOverlaps = foldr (||) False . combined overlaps
-- If the span list has duplicates, we have overlaps.

combined :: Eq a => (a -> a -> b) -> [a] -> [b]
combined f as = mcatMaybes [if x == y then Nothing else Just (x `f` y) | x <- as, y <- as]

squared :: (a -> a -> b) -> [a] -> [b]
squared f as = [x `f` y | x <- as, y <- as]
