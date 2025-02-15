-- Copyright (c) 2017-2018 Rudy Matela.
-- Distributed under the 3-Clause BSD licence (see the file LICENSE).
import Test

import Test.LeanCheck.Error (errorToNothing)

main :: IO ()
main = mainTest tests 5040

tests :: Int -> [Bool]
tests n =
  [ True

  -- Bool --

  , show b_ == "_ :: Bool"
  , show pp == "p :: Bool"
  , show qq == "q :: Bool"
  , show false == "False :: Bool"
  , show true == "True :: Bool"
  , show notE == "not :: Bool -> Bool"
  , show andE == "(&&) :: Bool -> Bool -> Bool"
  , show orE  == "(||) :: Bool -> Bool -> Bool"
  , show (not' false) == "not False :: Bool"
  , show (false -&&- true) == "False && True :: Bool"
  , show (pp -||- false) == "p || False :: Bool"
  , show (qq -&&- true) == "q && True :: Bool"

  , evl false == False
  , evl true  == True
  , holds n $ evl notE === not
  , holds n $ evl andE ==== (&&)
  , holds n $ evl orE  ==== (||)
  , evl (not' false) == True
  , evl (false -&&- true) == False
  , evl (false -||- true) == True
  , holds n $ \p -> evl (not' (val p)) == not p
  , holds n $ \p q -> evl (val p -&&- val q) == (p && q)
  , holds n $ \p q -> evl (val p -||- val q) == (p || q)

  -- Int --

  , show i_ == "_ :: Int"
  , show xx == "x :: Int"
  , show yy == "y :: Int"
  , show zz == "z :: Int"
  , show xx' == "x' :: Int"
  , show zero == "0 :: Int"
  , show two == "2 :: Int"
  , show minusOne == "-1 :: Int"

  , show plus == "(+) :: Int -> Int -> Int"
  , show times == "(*) :: Int -> Int -> Int"
  , show (plus :$ one) == "(1 +) :: Int -> Int"
  , show (times :$ two) == "(2 *) :: Int -> Int"

  , show (one -+- one)             == "1 + 1 :: Int"
  , show (minusOne -+- minusOne)   == "(-1) + (-1) :: Int"
  , show (minusTwo -*- two)        == "(-2) * 2 :: Int"
  , show (two -*- minusTwo)        == "2 * (-2) :: Int"
  , show (xx -+- (yy -+- zz))      == "x + (y + z) :: Int"

  , evl zero == (0 :: Int)
  , evl one  == (1 :: Int)
  , evl two   == (2 :: Int)
  , evl three == (3 :: Int)
  , evl minusOne == (-1 :: Int)
  , evl minusTwo == (-2 :: Int)

  , evl (one -+- one) == (2 :: Int)
  , evl (two -*- three) == (6 :: Int)
  , holds n $ \x y -> evl (val x -+- val y) == (x + y :: Int)
  , holds n $ \x y -> evl (val x -*- val y) == (x * y :: Int)
  , holds n $ \(IntE ex) (IntE ey) -> isGround ex && isGround ey ==> evl (ex -+- ey) =$ errorToNothing $= evl ex + (evl ey :: Int)
  , holds n $ \(IntE ex) (IntE ey) -> isGround ex && isGround ey ==> evl (ex -*- ey) =$ errorToNothing $= evl ex * (evl ey :: Int)

  , show xxs  == "xs :: [Int]"
  , show yys  == "ys :: [Int]"
  , show nil == "[] :: [Int]"
  , show (unit one) == "[1] :: [Int]"

  -- Int -> Int --

  , show ffE == "f :: Int -> Int"
  , show ggE == "g :: Int -> Int"
  , show (ff xx) == "f x :: Int"
  , show (gg yy) == "g y :: Int"
  , show (ff one) == "f 1 :: Int"
  , show (gg minusTwo) == "g (-2) :: Int"

  , show idE == "id :: Int -> Int"
  , show negateE == "negate :: Int -> Int"
  , show absE == "abs :: Int -> Int"
  , show (id' yy) == "id y :: Int"
  , show (id' one) == "id 1 :: Int"
  , show (id' true) == "id True :: Bool"
  , show (negate' yy) == "negate y :: Int"
  , show (abs' xx') == "abs x' :: Int"

  , evl (id' one) == (1 :: Int)
  , evl (id' true) == (True :: Bool)
  , evl (negate' one) == (-1 :: Int)
  , evl (abs' minusTwo) == (2 :: Int)

  , evl nil == ([] :: [Int])
  , evl (unit one) == [1 :: Int]

  -- Int -> Int -> Int
  , show (var "?" (undefined :: Int->Int->Int)) == "(?) :: Int -> Int -> Int"
  , show (var "?" (undefined :: Int->Int->Int) :$ xx) == "(x ?) :: Int -> Int"
  , show (xx -?- yy) == "x ? y :: Int"
  , show (pp -?- qq) == "p ? q :: Bool"
  , show (xxs -?- yys) == "xs ? ys :: [Int]"
  , show (bee -?- cee) == "'b' ? 'c' :: Char"

  -- Char --

  , show c_ == "_ :: Char"
  , show bee == "'b' :: Char"
  , show cee == "'c' :: Char"
  , show dee == "'d' :: Char"

  , evl bee == 'b'
  , evl cee == 'c'
  , evl dee == 'd'


  -- [a] & [Int] --

  , show xxs == "xs :: [Int]"
  , show yys == "ys :: [Int]"
  , show nil == "[] :: [Int]"
  , show cons == "(:) :: Int -> [Int] -> [Int]"
  , show (unit zero) == "[0] :: [Int]"
  , show (unit false) == "[False] :: [Bool]"
  , show (zero -:- one -:- unit two) == "[0,1,2] :: [Int]"
  , show (zero -:- one -:- two -:- nil) == "[0,1,2] :: [Int]"

  , evl nil == ([] :: [Int])
  , holds n $ \x -> evl (unit (val x)) == [x :: Int]
  , holds n $ \c -> evl (unit (val c)) == [c :: Char]
  , holds n $ \p -> evl (unit (val p)) == [p :: Bool]
  , holds n $ \x xs -> evl (val x -:- val xs) == (x:xs :: [Int])
  , holds n $ \p ps -> evl (val p -:- val ps) == (p:ps :: [Int])
  , holds n $ \c cs -> evl (val c -:- val cs) == (c:cs :: [Int])

  , show (nil -++- nil) == "[] ++ [] :: [Int]"
  , show ((zero -:- one -:- nil) -++- (two -:- three -:- nil)) == "[0,1] ++ [2,3] :: [Int]"

  , show (head' $ unit one) == "head [1] :: Int"
  , show (tail' $ unit one) == "tail [1] :: [Int]"
  , show (head' $ unit bee) == "head \"b\" :: Char"
  , show (tail' $ unit bee) == "tail \"b\" :: [Char]"
  , show (head' $ zero -:- unit two) == "head [0,2] :: Int"
  , show (tail' $ zero -:- unit two) == "tail [0,2] :: [Int]"

  , evl (unit one) == [1 :: Int]
  , evl (head' $ unit one) == (1 :: Int)
  , evl (tail' $ zero -:- unit two) == ([2] :: [Int])

  -- String --

  , show emptyString == "\"\" :: [Char]"
  , show (unit bee) == "\"b\" :: [Char]"
  , show (bee -:- unit cee) == "\"bc\" :: [Char]"
  , show (emptyString -++- emptyString) == "\"\" ++ \"\" :: [Char]"
  , show ((bee -:- unit cee) -++- unit dee) == "\"bc\" ++ \"d\" :: [Char]"

  , evl emptyString == ""
  , evl (unit bee) == "b"
  , evl (bee -:- unit cee) == "bc"
  , evl (bee -:- cee -:- unit dee) == "bcd"
  ]
