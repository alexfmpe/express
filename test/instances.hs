-- Copyright (c) 2017-2018 Rudy Matela.
-- Distributed under the 3-Clause BSD licence (see the file LICENSE).
{-# LANGUAGE NoMonomorphismRestriction #-} -- ACK!
import Test

main :: IO ()
main = mainTest tests 5040

tests :: Int -> [Bool]
tests n =
  [ True

  , eval undefined (eqFor (undefined :: Int) :$ one :$ one) == True
  , eval undefined (eqFor (undefined :: Int) :$ one :$ two) == False

  , eval undefined (compareFor (undefined :: Int) :$ one :$ two) == LT
  , eval undefined (compareFor (undefined :: Int) :$ one :$ one) == EQ
  , eval undefined (compareFor (undefined :: Int) :$ two :$ one) == GT

  , eval undefined (nameFor (undefined :: Int)  :$ xx) == "x"
  , eval undefined (nameFor (undefined :: Int)  :$ yy) == "x"
  , eval undefined (nameFor (undefined :: Bool) :$ pp) == "p"
  , eval undefined (nameFor (undefined :: Bool) :$ qq) == "p"

  , length (validApps functions one) == 6
  ]
  where
  eqFor = head . reifyEq
  compareFor = head . reifyOrd
  nameFor = head . reifyName

functions :: [Expr]
functions  =  concat
  [ reifyEq (undefined :: Int)
  , reifyEq (undefined :: Bool)
  , reifyOrd (undefined :: Int)
  , reifyOrd (undefined :: Bool)
  , reifyName (undefined :: Int)
  , reifyName (undefined :: Bool)
  ]
