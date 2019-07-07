-- Copyright (c) 2017-2018 Rudy Matela.  -- Distributed under the 3-Clause BSD licence (see the file LICENSE).
import Test

main :: IO ()
main = mainTest tests 5040

tests :: Int -> [Bool]
tests n =
  [ True

  , canonicalize (xx -+- yy)
              == (xx -+- yy)
  , canonicalize (jj -+- (ii -+- ii))
              == (xx -+- (yy -+- yy))
  , canonicalize ((jj -+- ii) -+- (xx -+- xx))
              == ((xx -+- yy) -+- (zz -+- zz))

  -- these are just tests:
  -- canonicalizeWith expects the resulting list of the arg function to be infinite
  , canonicalizeWith (const ["i","j","k","l"]) (xx -+- yy)
                                            == (ii -+- jj)
  , canonicalizeWith (const ["i","j","k","l"]) (jj -+- (ii -+- ii))
                                            == (ii -+- (jj -+- jj))
  , canonicalizeWith (const ["i","j","k","l"]) ((jj -+- ii) -+- (xx -+- xx))
                                            == ((ii -+- jj) -+- (kk -+- kk))

  , canonicalize (xx -+- ord' cc) == (xx -+- ord' cc)


  -- canonicalizing holes --
  , canonicalize (hole (undefined :: Int       )) == xx
  , canonicalize (hole (undefined :: Bool      )) == pp
  , canonicalize (hole (undefined :: Char      )) == cc
  , canonicalize (hole (undefined :: [Int]     )) == xxs
  , canonicalize (hole (undefined :: [Char]    )) == ccs
  , canonicalize (hole (undefined :: ()        )) == var "u" ()
  , canonicalize (hole (undefined :: Integer   )) == var "x" (undefined :: Integer)
  , canonicalize (hole (undefined :: [Integer] )) == var "xs" (undefined :: [Integer])
  , canonicalize (hole (undefined :: Maybe Int )) == var "mx" (undefined :: Maybe Int)
  , canonicalize (hole (undefined :: (Int,Int) )) == var "xy" (undefined :: (Int,Int))

  , canonicalVariations (zero -+- xx) == [zero -+- xx]
  , canonicalVariations (zero -+- i_) == [zero -+- xx]
  , canonicalVariations (i_ -+- i_) == [xx -+- yy, xx -+- xx]
  , map canonicalize (canonicalVariations (i_ -+- (i_ -+- ord' c_)))
    == [ xx -+- (yy -+- ord' cc)
       , xx -+- (xx -+- ord' cc) ]

  , canonicalVariations (ii -+- i_) == [ii -+- xx]
  , map canonicalize (canonicalVariations ((i_ -+- i_) -+- (ord' c_ -+- ord' c_)))
    == [ (xx -+- yy) -+- (ord' cc -+- ord' dd)
       , (xx -+- yy) -+- (ord' cc -+- ord' cc)
       , (xx -+- xx) -+- (ord' cc -+- ord' dd)
       , (xx -+- xx) -+- (ord' cc -+- ord' cc) ]
  ]
