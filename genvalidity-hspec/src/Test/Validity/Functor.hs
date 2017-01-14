{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE AllowAmbiguousTypes #-}

-- | Functor properties
--
-- You will need @TypeApplications@ to use these.
module Test.Validity.Functor
    ( functorSpecOnValid
    , functorSpec
    , functorSpecOnArbitrary
    , functorSpecOnGens
    ) where

import Data.Data

import Data.GenValidity

import Test.Hspec
import Test.QuickCheck

import Test.Validity.Functions
import Test.Validity.Operations
import Test.Validity.Relations
import Test.Validity.Utils

fmapTypeStr
    :: forall (f :: * -> *).
       (Typeable f)
    => String
fmapTypeStr =
    unwords
        [ "fmap"
        , "::"
        , "(a"
        , "->"
        , "b)"
        , "->"
        , nameOf @f
        , "a"
        , "->"
        , nameOf @f
        , "b"
        ]

flTypeStr
    :: forall (f :: * -> *).
       (Typeable f)
    => String
flTypeStr =
    unwords ["(<$)", "::", "a", "->", nameOf @f, "b", "->", nameOf @f, "a"]

-- | Standard test spec for properties of Functor instances for values generated with GenValid instances
--
-- Example usage:
--
-- > functorSpecOnArbitrary @[]
functorSpecOnValid
    :: forall (f :: * -> *).
       (Eq (f Int), Show (f Int), Functor f, Typeable f, GenValid (f Int))
    => Spec
functorSpecOnValid = functorSpecWithInts @f genValid

-- | Standard test spec for properties of Functor instances for values generated with GenUnchecked instances
--
-- Example usage:
--
-- > functorSpecOnArbitrary @[]
functorSpec
    :: forall (f :: * -> *).
       (Eq (f Int), Show (f Int), Functor f, Typeable f, GenUnchecked (f Int))
    => Spec
functorSpec = functorSpecWithInts @f genUnchecked

-- | Standard test spec for properties of Functor instances for values generated with Arbitrary instances
--
-- Example usage:
--
-- > functorSpecOnArbitrary @[]
functorSpecOnArbitrary
    :: forall (f :: * -> *).
       (Eq (f Int), Show (f Int), Functor f, Typeable f, Arbitrary (f Int))
    => Spec
functorSpecOnArbitrary = functorSpecWithInts @f arbitrary

functorSpecWithInts
    :: forall (f :: * -> *).
       (Eq (f Int), Show (f Int), Functor f, Typeable f)
    => Gen (f Int) -> Spec
functorSpecWithInts gen =
    functorSpecOnGens
        @f
        @Int
        genUnchecked
        "int"
        gen
        "f of ints"
        ((+) <$> genUnchecked)
        "additions"
        ((*) <$> genUnchecked)
        "multiplications"

-- | Standard test spec for properties of Functor instances for values generated by given generators (and names for those generator).
--
-- Example usage:
--
-- > functorSpecOnGens
-- >     @[]
-- >     @Int
-- >     (pure 4) "four"
-- >     (genListOf $ pure 5) "list of fives"
-- >     ((+) <$> genValid) "additions"
-- >     ((*) <$> genValid) "multiplications"
functorSpecOnGens
    :: forall (f :: * -> *) (a :: *) (b :: *) (c :: *).
       ( Show a
       , Show (f a)
       , Show (f c)
       , Eq (f a)
       , Eq (f c)
       , Functor f
       , Typeable f
       , Typeable a
       , Typeable b
       , Typeable c
       )
    => Gen a
    -> String
    -> Gen (f a)
    -> String
    -> Gen (b -> c)
    -> String
    -> Gen (a -> b)
    -> String
    -> Spec
functorSpecOnGens gena genaname gen genname genf genfname geng gengname =
    parallel $
    describe ("Functor " ++ nameOf @f) $ do
        describe (fmapTypeStr @f) $ do
            it
                (unwords
                     [ "satisfies the first Fuctor law: 'fmap id == id' for"
                     , genDescr @(f a) genname
                     ]) $
                equivalentOnGen (fmap @f id) (id @(f a)) gen
            it
                (unwords
                     [ "satisfieds the second Functor law: 'fmap (f . g) == fmap f . fmap g' for"
                     , genDescr @(f a) genname
                     , "'s"
                     , "given to"
                     , genDescr @(b -> c) genfname
                     , "and"
                     , genDescr @(a -> b) gengname
                     ]) $
                forAll (Anon <$> genf) $ \(Anon f) ->
                    forAll (Anon <$> geng) $ \(Anon g) ->
                        equivalentOnGen (fmap (f . g)) (fmap f . fmap g) gen
        describe (flTypeStr @f) $
            it
                (unwords
                     [ "is equivalent to its default implementation for"
                     , genDescr @a genaname
                     , "and"
                     , genDescr @(f a) genname
                     ]) $
            forAll gena $ \a -> equivalentOnGen ((<$) a) (fmap $ const a) gen

data Anon a =
    Anon a

instance Show (Anon a) where
    show _ = "Anonymous"

instance Functor Anon where
    fmap f (Anon a) = Anon (f a)
