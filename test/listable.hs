-- Copyright (c) 2017-2018 Rudy Matela.
-- Distributed under the 3-Clause BSD licence (see the file LICENSE).
import Test

main :: IO ()
main = mainTest tests 360

tests :: Int -> [Bool]
tests n =
  [ True

  -- Listable Expr only produces well-typed expressions
  , holds n $ isJust . toDynamic
  , holds n $ isJust . mtyp

  -- Listable Ill only produces ill-typed expressions
  , holds n $ isNothing . toDynamic . unIll
  , holds n $ isNothing . mtyp      . unIll

  -- Listable TypeE produces expressions of the right type
  , holds n $ isJust . evaluateInt      . unIntE
  , holds n $ isJust . evaluateBool     . unBoolE
  , holds n $ isJust . evaluateInts     . unIntsE
  , holds n $ isJust . evaluateIntToInt . unIntToIntE

  , holds n $ \(IntToIntE ff) (IntE xx) -> isJust . evaluateInt $ ff :$ xx
  , holds n $ \(IntToIntToIntE ff) (IntE xx) (IntE yy) -> isJust . evaluateInt $ ff :$ xx :$ yy

  -- Listable TypeE does not produce expressions of the wrong type
  , holds n $ isNothing . evaluateInt      . unBoolE
  , holds n $ isNothing . evaluateBool     . unIntE
  , holds n $ isNothing . evaluateInts     . unIntE
  , holds n $ isNothing . evaluateIntToInt . unIntE

  -- Listable TypeE0 only returns terminal constants
  , holds n $ isConst . unE0
  , holds n $ isConst . unIntE0
  , holds n $ isConst . unBoolE0
  , holds n $ isConst . unIntsE0

  -- Listable TypeEV only returns variables
  , holds n $ isVar . unEV
  , holds n $ isVar . unIntEV
  , holds n $ isVar . unBoolEV
  , holds n $ isVar . unIntsEV

  -- counter-examples are of the right type
  , (counterExample n $ \(IntE xx) -> False) == Just ["_ :: Int"]
  ]

evaluateInt :: Expr -> Maybe Int
evaluateInt = evaluate

evaluateBool :: Expr -> Maybe Bool
evaluateBool = evaluate

evaluateInts :: Expr -> Maybe [Int]
evaluateInts = evaluate

evaluateIntToInt :: Expr -> Maybe (Int -> Int)
evaluateIntToInt = evaluate
