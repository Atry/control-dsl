{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE RebindableSyntax #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE RankNTypes #-}

module Control.Dsl.State.State where

import Control.Dsl.PolyCont
import Prelude hiding ((>>), (>>=), return)

{- |
The type that holds states, which is defined as a plain function.

==== __Examples__

>>> :set -XFlexibleContexts
>>> :set -XTypeApplications
>>> :set -XRebindableSyntax
>>> import Prelude hiding ((>>), (>>=), return)
>>> import Control.Dsl
>>> import Control.Dsl.Cont
>>> import Control.Dsl.Shift
>>> import Control.Dsl.State
>>> import Data.Sequence
>>> import Data.Foldable

The following @append@ function 'Control.Dsl.State.Get's a @Seq String@ state,
appends @s@ to the 'Data.Sequence.Seq',
and 'Control.Dsl.State.Put's the new 'Data.Sequence.Seq' to the updated state.

>>> :{
append s = do
  buffer <- Get @(Seq String)
  Put $ buffer |> s
  Cont ($ ())
:}

@($ ())@ creates a CPS function ,
which can be then converted to 'Control.Dsl.Cont.Cont's.

A @formatter@ @append@s 'String' to its internal buffer,
and 'Control.Dsl.return' the concatenated buffer.

>>> :{
formatter = do
  append "x="
  d <- Get @Double
  append $ show d
  append ",y="
  i <- Get @Integer
  append $ show i
  buffer <- Get @(Seq String)
  return $ concat buffer
:}

>>> x = 0.5 :: Double
>>> y = 42 :: Integer
>>> initialBuffer = Empty :: Seq String
>>> formatter x y initialBuffer :: String
"x=0.5,y=42"

Note that @formatter@ accepts arbitrary order of the parameters,
or additional unused parameters.

>>> formatter "unused parameter" initialBuffer y x :: String
"x=0.5,y=42"
-}
type State a b = a -> b

instance {-# OVERLAPS #-} PolyCont k r a => PolyCont k (State b r) a where
  runPolyCont k f b = runPolyCont k $ \a -> f a b