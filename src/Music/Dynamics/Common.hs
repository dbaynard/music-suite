
-------------------------------------------------------------------------------------
-- |
-- Copyright   : (c) Hans Hoglund 2012
--
-- License     : BSD-style
--
-- Maintainer  : hans@hanshoglund.se
-- Stability   : experimental
-- Portability : portable
--
-- Provides relative dynamics.
--
-------------------------------------------------------------------------------------

module Music.Dynamics.Common (
  Dynamics,
)
where

import Data.Maybe
import Data.Either
import Data.Semigroup
import Control.Monad
import Control.Applicative
import Data.Monoid.Average

type Dynamics = Average Double