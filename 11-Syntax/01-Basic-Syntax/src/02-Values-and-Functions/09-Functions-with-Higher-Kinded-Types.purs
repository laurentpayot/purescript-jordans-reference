module Syntax.Function.HigherKindedTypes where

import Prelude

-- == Review ==
data Box a = Box a
-- `Box a` is a higher-kinded type. In other words, it has a kind of `* -> *`,
-- not `*` like Int. It still needs a type to be specified before it is fully
-- concrete.

-- we can define a function when the 'a' of Box is known (Int in this case)...
add1 :: Box Int -> Box Int
add1 (Box x) = Box (x + 1)

-- we can also define a function when 'a' of Box is not known
modify :: forall a. Box a -> (a -> a) -> Box a
modify (Box a) function = Box (function a)

-- However, how might one write a function that works on all of
-- the four types below? In other words, how would we define a function
-- when we know we will have a higher-kinded type like `Box`,but
-- we don't know the exact type?

data Box1 a = Box1 a
data Box2 a = Box2 a
data Box3 a = Box3 a
data Box4 a = Box4 a

-- The following function shows the syntax to follow. When using
--   higher-kinded types, convention is to start with `f` and continue down
--   the alphabet for each higher-kinded type thereafter (e.g. `g`, `h`, etc.).
-- I think the convention of using 'f' has something to do with a typeclass
--   called Functor.
hktFunction :: forall f a. f a -> f a
hktFunction boxN = boxN
-- One should understand `f a` as "f is a higher-kinded type that needs
-- one type, `a`, specified before it can be a concrete instance".

-- If the higher-kinded type we want to include in our function takes more than
-- one type, we just add the extra types beyond it
data HigherKindedTypeWith4Types a b c d = Constructor a b c d

hktFunction2 :: forall f a b c d. f a b c d -> f a b c d
hktFunction2 f_abcd = f_abcd
-- Read "f a b c d" as "F is a higher-kinded type that takes
-- 4 types, 'a', 'b', 'c', and 'd', all of which need to be specified
-- before 'f' can be a concrete type of kind `*`"

-- We can also specify specific types in the function:
hktFunction3 :: forall f a b c. f a b c Int -> f a b c Int
hktFunction3 f_abc_Int = f_abc_Int
-- Read "f a b c d" as "F is a higher-kinded type that takes
-- 4 types, 'a', 'b', 'c', and 'd', all of which need to be specified
-- before 'f' can be a concrete type of kind `*`. `d` must be specified
-- to the 'Int' type for the compiler to accept calling this function with 'F'"

-- Returning to our previous question...
boxFunction :: forall f a. f a -> (f a -> a) -> (a -> a) -> (a -> f a) -> f a
boxFunction boxN unwrap changeA rewrap =
  rewrap (changeA (unwrap boxN))
-- The unwrap and rewrap functions in the above function are only needed to make
-- this compile. In many functions, they won't be needed due to typeclasses.

-- If we specified functions like below for each of the box type...
unwrapBox2 :: forall a. Box2 a -> a
unwrapBox2 (Box2 a) = a

rewrapBox2 :: forall a. a -> Box2 a
rewrapBox2 a = Box2 a

{-
The following code would compile
   (boxFunction (Box2 2) unwrapBox2 (_ + 1) rewrapBox2) == Box2 3
   (boxFunction (Box3 3) unwrapBox3 (_ + 1) rewrapBox3) == Box3 4
-}

-- Keep in mind that any type that follows a 'forall' keyword could be
-- a higher-kinded type