-- |
-- Module      : Data.Haexpress.Express
-- Copyright   : (c) 2019 Rudy Matela
-- License     : 3-Clause BSD  (see the file LICENSE)
-- Maintainer  : Rudy Matela <rudy@matela.com.br>
--
-- Defines the 'Express' type class.
{-# LANGUAGE CPP #-}
module Data.Haexpress.Express (Express (..)) where

import Data.Haexpress.Core
import Data.Typeable
import Data.Ratio

-- |
-- 'Express' typeclass instances provide an 'expr' function
-- that allows values to be deeply encoded as applications of 'Expr's.
--
-- > expr False  =  val False
-- > expr (Just True)  =  value "Just" (Just :: Bool -> Maybe Bool) :$ val True
--
-- The function 'expr' can be contrasted with the function 'val':
--
-- * 'val' always encodes values as atomic 'Value' 'Expr's --
--   shallow encoding.
-- * 'expr' ideally encodes expressions as applications (':$')
--   between 'Value' 'Expr's --
--   deep encoding.
--
-- Depending on the situation, one or the other may be desirable.
--
-- Instances can be automatically derived using the TH function
-- 'Data.Haexpress.Express.Derive.deriveExpress'.
class Typeable a => Express a where
  expr :: a -> Expr

instance Express ()        where  expr  =  val
instance Express Bool      where  expr  =  val
instance Express Int       where  expr  =  val
instance Express Integer   where  expr  =  val
instance Express Char      where  expr  =  val
instance Express Ordering  where  expr  =  val

instance Express a => Express (Maybe a) where
  expr mx@Nothing   =  value "Nothing" (Nothing -: mx)
  expr mx@(Just x)  =  value "Just"    (Just   ->: mx) :$ expr x

instance (Express a, Express b) => Express (Either a b) where
  expr lx@(Left x)   =  value "Left"  (Left  ->: lx) :$ expr x
  expr ry@(Right y)  =  value "Right" (Right ->: ry) :$ expr y

instance (Express a, Express b) => Express (a,b) where
  expr (x,y)  =  value "," ((,) ->>: (x,y))
              :$ expr x :$ expr y

instance (Express a, Express b, Express c) => Express (a,b,c) where
  expr (x,y,z)  =  value ",," ((,,) ->>>: (x,y,z))
                :$ expr x :$ expr y :$ expr z

instance (Express a, Express b, Express c, Express d) => Express (a,b,c,d) where
  expr (x,y,z,w)  =  value ",,," ((,,,) ->>>>: (x,y,z,w))
                  :$ expr x :$ expr y :$ expr z :$ expr w

instance Express a => Express [a] where
  expr xs@[]
    | typeOf xs == typeOf ""  =  value "\"\"" ([] -: xs)
    | otherwise               =  value "[]" ([] -: xs)
  expr xs@(y:ys)              =  value ":"  ((:) ->>: xs) :$ expr y :$ expr ys


-- instances of further types and arities --

instance (Show a, Express a) => Express (Ratio a) where
  expr  =  val
-- The following would allow zero denominators
-- expr (n % d) = constant "%" ((%) -:> n) :$ expr n :$ expr d
-- TODO: allow zero denominators as it is not our problem
--       but only after refactoring Extrapolate to use Haexpress

instance (Express a, Express b, Express c, Express d, Express e)
      => Express (a,b,c,d,e) where
  expr (x,y,z,w,v)  =  value ",,,," ((,,,,) ->>>>>: (x,y,z,w,v))
                    :$ expr x :$ expr y :$ expr z :$ expr w :$ expr v

instance (Express a, Express b, Express c, Express d, Express e, Express f)
      => Express (a,b,c,d,e,f) where
  expr (x,y,z,w,v,u)  =  value ",,,,," ((,,,,,) ->>>>>>: (x,y,z,w,v,u))
                    :$ expr x :$ expr y :$ expr z :$ expr w :$ expr v :$ expr u

instance ( Express a, Express b, Express c, Express d, Express e, Express f
         , Express g )
      => Express (a,b,c,d,e,f,g) where
  expr (x,y,z,w,v,u,t)  =  value ",,,,,," ((,,,,,,) ->>>>>>>: (x,y,z,w,v,u,t))
                        :$ expr x :$ expr y :$ expr z :$ expr w
                        :$ expr v :$ expr u :$ expr t

#if __GLASGOW_HASKELL__ < 710
-- No 8-tuples for you:
-- On GHC 7.8, 8-tuples are not Typeable instances.  We could add a standalone
-- deriving clause, but that may cause trouble if some other library does the
-- same.  User should declare Generalizable 8-tuples manually when using GHC <=
-- 7.8.
#else
instance ( Express a, Express b, Express c, Express d, Express e, Express f
         , Express g, Express h )
      => Express (a,b,c,d,e,f,g,h) where
  expr (x,y,z,w,v,u,t,s)  =
    value ",,,,,,," ((,,,,,,,) ->>>>>>>>: (x,y,z,w,v,u,t,s))
      :$ expr x :$ expr y :$ expr z :$ expr w
      :$ expr v :$ expr u :$ expr t :$ expr s

instance ( Express a, Express b, Express c, Express d, Express e, Express f
         , Express g, Express h, Express i )
      => Express (a,b,c,d,e,f,g,h,i) where
  expr (x,y,z,w,v,u,t,s,r)  =
    value ",,,,,,,," ((,,,,,,,,) ->>>>>>>>>: (x,y,z,w,v,u,t,s,r))
      :$ expr x :$ expr y :$ expr z :$ expr w
      :$ expr v :$ expr u :$ expr t :$ expr s
      :$ expr r

instance ( Express a, Express b, Express c, Express d, Express e, Express f
         , Express g, Express h, Express i, Express j )
      => Express (a,b,c,d,e,f,g,h,i,j) where
  expr (x,y,z,w,v,u,t,s,r,q)  =
    value ",,,,,,,,," ((,,,,,,,,,) ->>>>>>>>>>: (x,y,z,w,v,u,t,s,r,q))
      :$ expr x :$ expr y :$ expr z :$ expr w
      :$ expr v :$ expr u :$ expr t :$ expr s
      :$ expr r :$ expr q

instance ( Express a, Express b, Express c, Express d, Express e, Express f
         , Express g, Express h, Express i, Express j, Express k )
      => Express (a,b,c,d,e,f,g,h,i,j,k) where
  expr (x,y,z,w,v,u,t,s,r,q,p)  =
    value ",,,,,,,,,," ((,,,,,,,,,,) ->>>>>>>>>>>: (x,y,z,w,v,u,t,s,r,q,p))
      :$ expr x :$ expr y :$ expr z :$ expr w
      :$ expr v :$ expr u :$ expr t :$ expr s
      :$ expr r :$ expr q :$ expr p

instance ( Express a, Express b, Express c, Express d, Express e, Express f
         , Express g, Express h, Express i, Express j, Express k, Express l )
      => Express (a,b,c,d,e,f,g,h,i,j,k,l) where
  expr (x,y,z,w,v,u,t,s,r,q,p,o)  =
    value ",,,,,,,,,,," ((,,,,,,,,,,,) ->>>>>>>>>>>>: (x,y,z,w,v,u,t,s,r,q,p,o))
      :$ expr x :$ expr y :$ expr z :$ expr w
      :$ expr v :$ expr u :$ expr t :$ expr s
      :$ expr r :$ expr q :$ expr p :$ expr o
#endif

-- type binding utilities --

(-:) :: a -> a -> a
(-:) = asTypeOf -- const
infixl 1 -:

(-:>) :: (a -> b) -> a -> (a -> b)
(-:>) = const
infixl 1 -:>

(->:) :: (a -> b) -> b -> (a -> b)
(->:) = const
infixl 1 ->:

(->:>) :: (a -> b -> c) -> b -> (a -> b -> c)
(->:>) = const
infixl 1 ->:>

(->>:) :: (a -> b -> c) -> c -> (a -> b -> c)
(->>:) = const
infixl 1 ->>:

(->>:>) :: (a -> b -> c -> d) -> c -> (a -> b -> c -> d)
(->>:>) = const
infixl 1 ->>:>

(->>>:) :: (a -> b -> c -> d) -> d -> (a -> b -> c -> d)
(->>>:) = const
infixl 1 ->>>:

(->>>:>) :: (a -> b -> c -> d -> e) -> d -> (a -> b -> c -> d -> e)
(->>>:>) = const
infixl 1 ->>>:>

(->>>>:) :: (a -> b -> c -> d -> e) -> e -> (a -> b -> c -> d -> e)
(->>>>:) = const
infixl 1 ->>>>:

(->>>>:>) :: (a -> b -> c -> d -> e -> f) -> e -> (a -> b -> c -> d -> e -> f)
(->>>>:>) = const
infixl 1 ->>>>:>

(->>>>>:) :: (a -> b -> c -> d -> e -> f) -> f -> (a -> b -> c -> d -> e -> f)
(->>>>>:) = const
infixl 1 ->>>>>:

(->>>>>:>) :: (a->b->c->d->e->f->g) -> f -> (a->b->c->d->e->f->g)
(->>>>>:>) = const
infixl 1 ->>>>>:>

(->>>>>>:) :: (a->b->c->d->e->f->g) -> g -> (a->b->c->d->e->f->g)
(->>>>>>:) = const
infixl 1 ->>>>>>:

(->>>>>>>:) :: (a->b->c->d->e->f->g->h) -> h -> (a->b->c->d->e->f->g->h)
(->>>>>>>:) = const
infixl 1 ->>>>>>>:

(->>>>>>>>:) :: (a->b->c->d->e->f->g->h->i) -> i -> (a->b->c->d->e->f->g->h->i)
(->>>>>>>>:) = const
infixl 1 ->>>>>>>>:

(->>>>>>>>>:) :: (a->b->c->d->e->f->g->h->i->j) -> j
              -> (a->b->c->d->e->f->g->h->i->j)
(->>>>>>>>>:) = const
infixl 1 ->>>>>>>>>:

(->>>>>>>>>>:) :: (a->b->c->d->e->f->g->h->i->j->k) -> k
               -> (a->b->c->d->e->f->g->h->i->j->k)
(->>>>>>>>>>:) = const
infixl 1 ->>>>>>>>>>:

(->>>>>>>>>>>:) :: (a->b->c->d->e->f->g->h->i->j->k->l) -> l
                -> (a->b->c->d->e->f->g->h->i->j->k->l)
(->>>>>>>>>>>:) = const
infixl 1 ->>>>>>>>>>>:

(->>>>>>>>>>>>:) :: (a->b->c->d->e->f->g->h->i->j->k->l->m) -> m
                 -> (a->b->c->d->e->f->g->h->i->j->k->l->m)
(->>>>>>>>>>>>:) = const
infixl 1 ->>>>>>>>>>>>:
