{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables   #-}
module Test.Validity.Functions.Validity
    ( -- ** Standard tests involving validity
      producesValidsOnGen
    , producesValidsOnValids
    , producesValid
    , producesValidsOnArbitrary
    , producesValidsOnGens2
    , producesValidsOnValids2
    , producesValid2
    , producesValidsOnArbitrary2
    , producesValidsOnGens3
    , producesValidsOnValids3
    , producesValid3
    , producesValidsOnArbitrary3
    ) where

import           Data.GenValidity

import           Test.Hspec
import           Test.QuickCheck

-- | The function produces valid output when the input is generated as
-- specified by the given generator.
producesValidsOnGen
    :: (Show a, Show b, Validity b)
    => (a -> b)
    -> Gen a
    -> Property
producesValidsOnGen func gen
    = forAll gen $ \a -> func a `shouldSatisfy` isValid

-- | The function produces valid output when the input is generated by
-- @arbitrary@
producesValidsOnArbitrary
    :: (Show a, Show b, Arbitrary a, Validity b)
    => (a -> b)
    -> Property
producesValidsOnArbitrary = (`producesValidsOnGen` arbitrary)

-- | The function produces valid output when the input is generated by
-- @genUnchecked@
producesValid
    :: (Show a, Show b, GenValidity a, Validity b)
    => (a -> b)
    -> Property
producesValid = (`producesValidsOnGen` genUnchecked)

-- | The function produces valid output when the input is generated by
-- @genValid@
producesValidsOnValids
    :: (Show a, Show b, GenValidity a, Validity b)
    => (a -> b)
    -> Property
producesValidsOnValids = (`producesValidsOnGen` genValid)

producesValidsOnGens2
    :: (Show a, Show b, Show c, Validity c)
    => (a -> b -> c)
    -> Gen (a, b)
    -> Property
producesValidsOnGens2 func gen
    = forAll gen $ \(a, b) ->
        func a b `shouldSatisfy` isValid

producesValidsOnValids2
    :: (Show a, Show b, Show c, GenValidity a, GenValidity b, Validity c)
    => (a -> b -> c)
    -> Property
producesValidsOnValids2 func
    = producesValidsOnGens2 func genValid

producesValidsOnArbitrary2
    :: (Show a, Show b, Show c, Arbitrary a, Arbitrary b, Validity c)
    => (a -> b -> c)
    -> Property
producesValidsOnArbitrary2 func
    = producesValidsOnGens2 func arbitrary

producesValid2
    :: (Show a, Show b, Show c, GenValidity a, GenValidity b, Validity c)
    => (a -> b -> c)
    -> Property
producesValid2 func
    = producesValidsOnGens2 func genUnchecked

producesValidsOnGens3
    :: (Show a, Show b, Show c, Show d, Validity d)
    => (a -> b -> c -> d)
    -> Gen (a, b, c)
    -> Property
producesValidsOnGens3 func gen
    = forAll gen $ \(a, b, c) ->
        func a b c `shouldSatisfy` isValid

producesValid3
    :: (Show a, Show b, Show c, Show d,
        GenValidity a, GenValidity b, GenValidity c,
        Validity d)
    => (a -> b -> c -> d)
    -> Property
producesValid3 func
    = producesValidsOnGens3 func genUnchecked

producesValidsOnValids3
    :: (Show a, Show b, Show c, Show d,
        GenValidity a, GenValidity b, GenValidity c,
        Validity d)
    => (a -> b -> c -> d)
    -> Property
producesValidsOnValids3 func
    = producesValidsOnGens3 func genValid

producesValidsOnArbitrary3
    :: (Show a, Show b, Show c, Show d,
        Arbitrary a, Arbitrary b, Arbitrary c,
        Validity d)
    => (a -> b -> c -> d)
    -> Property
producesValidsOnArbitrary3 func
    = producesValidsOnGens3 func arbitrary
