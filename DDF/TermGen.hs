{-# LANGUAGE
  RankNTypes,
  ConstraintKinds,
  NoImplicitPrelude,
  KindSignatures,
  TypeOperators,
  MultiParamTypeClasses,
  FlexibleContexts,
  UndecidableInstances,
  FlexibleInstances,
  TypeFamilies,
  UndecidableSuperClasses,
  TemplateHaskell,
  TypeApplications,
  ScopedTypeVariables,
  PartialTypeSignatures,
  AllowAmbiguousTypes
#-}

module DDF.TermGen (module DDF.TermGen, module DDF.Lang) where

import DDF.Lang
import qualified DDF.Map as Map
import qualified DDF.VectorTF as VTF

import qualified Prelude as M
import Language.Haskell.TH

type family SubLC (l :: (* -> * -> *) -> Constraint) (r :: (* -> * -> *) -> Constraint) :: Constraint

class SubLC l r => SubL l r where
  sub :: forall repr. l repr :- r repr

newtype Term c h s = Term { runTerm :: forall r. c r => r h s }

mkT :: forall r l h s. (SubL l r) =>
  (forall (repr :: * -> * -> *). (l repr, r repr) => repr h s) ->
  Term l h s

mkT f = Term k
  where
    k :: forall repr. l repr => repr h s
    k = f @repr \\ sub @l @r @repr

type instance SubLC c DBI = ()

instance SubL c DBI => DBI (Term c) where
  z = mkT @DBI z
  s (Term x) = mkT @DBI (s x)
  abs (Term x) = mkT @DBI (abs x)
  app (Term f) (Term x) = mkT @DBI (app f x)

type instance SubLC c Bool = SubL c DBI

instance SubL c Bool => Bool (Term c) where
  ite = mkT @Bool ite
  bool x = mkT @Bool (bool x)

type instance SubLC c Int = SubL c Bool

instance SubL c Int => Int (Term c) where
  pred = mkT @Int pred
  int x = mkT @Int (int x)
  isZero = mkT @Int isZero

type instance SubLC c Fix = SubL c DBI

instance SubL c Fix => Fix (Term c) where
  fix = mkT @Fix fix
  runFix = mkT @Fix runFix

type instance SubLC c Lang = (
  SubL c Fix,
  SubL c Int,
  SubL c Float,
  SubL c Double,
  SubL c Bimap,
  SubL c IO,
  SubL c Sum,
  SubL c Dual,
  SubL c DiffWrapper,
  SubL c FreeVector,
  SubL c VTF.VectorTF)

instance SubL c Lang => Lang (Term c) where
  state = mkT @Lang state
  writer = mkT @Lang writer
  exfalso = mkT @Lang exfalso
  runState = mkT @Lang runState
  runWriter = mkT @Lang runWriter
  float2Double = mkT @Lang float2Double
  double2Float = mkT @Lang double2Float

type instance SubLC c FreeVector = SubL c DBI

instance SubL c FreeVector => FreeVector (Term c) where
  freeVector = mkT @FreeVector freeVector
  runFreeVector = mkT @FreeVector runFreeVector

type instance SubLC c DiffWrapper = SubL c DBI

instance SubL c DiffWrapper => DiffWrapper (Term c) where
  diffWrapper = mkT @DiffWrapper diffWrapper
  runDiffWrapper = mkT @DiffWrapper runDiffWrapper

type instance SubLC c Char = SubL c DBI

instance SubL c Char => Char (Term c) where
  char x = mkT @Char (char x)

type instance SubLC c Bimap = (SubL c Int, SubL c Map.Map)

instance SubL c Bimap => Bimap (Term c) where
  size = mkT @Bimap size
  empty = mkT @Bimap empty
  insert = mkT @Bimap insert
  toMapL = mkT @Bimap toMapL
  toMapR = mkT @Bimap toMapR
  lookupL = mkT @Bimap lookupL
  lookupR = mkT @Bimap lookupR
  updateL = mkT @Bimap updateL
  updateR = mkT @Bimap updateR
  singleton = mkT @Bimap singleton

type instance SubLC c Float = SubL c DBI

instance SubL c Float => Float (Term c) where
  float x = mkT @Float (float x) 
  floatExp = mkT @Float floatExp
  floatPlus = mkT @Float floatPlus
  floatMult = mkT @Float floatMult
  floatMinus = mkT @Float floatMinus
  floatDivide = mkT @Float floatDivide

type instance SubLC c Double = SubL c Bool

instance SubL c Double => Double (Term c) where
  doubleEq = mkT @Double doubleEq
  double x = mkT @Double (double x)
  doubleExp = mkT @Double doubleExp
  doublePlus = mkT @Double doublePlus  
  doubleMult = mkT @Double doubleMult
  doubleMinus = mkT @Double doubleMinus
  doubleDivide = mkT @Double doubleDivide

type instance SubLC c Dual = SubL c Prod

instance SubL c Dual => Dual (Term c) where
  dual = mkT @Dual dual
  runDual = mkT @Dual runDual

type instance SubLC c Unit = SubL c DBI

instance SubL c Unit => Unit (Term c) where
  unit = mkT @Unit unit

type instance SubLC c Sum = SubL c DBI

instance SubL c Sum => Sum (Term c) where
  left = mkT @Sum left
  right = mkT @Sum right
  sumMatch = mkT @Sum sumMatch

type instance SubLC c IO = (SubL c Unit, SubL c Char, SubL c List)

instance SubL c IO => IO (Term c) where
  putStrLn = mkT @IO putStrLn

instance SubL c IO => Functor (Term c) M.IO where
  map = mkT @IO map

instance SubL c IO => Applicative (Term c) M.IO where
  ap = mkT @IO ap
  pure = mkT @IO pure

instance SubL c IO => Monad (Term c) M.IO where
  join = mkT @IO join
  bind = mkT @IO bind

type instance SubLC c List = SubL c Y

instance SubL c List => List (Term c) where
  nil = mkT @List nil
  cons = mkT @List cons
  listMatch = mkT @List listMatch

type instance SubLC c Prod = SubL c DBI

instance SubL c Prod => Prod (Term c) where
  zro = mkT @Prod zro
  fst = mkT @Prod fst
  mkProd = mkT @Prod mkProd

type instance SubLC c Y = SubL c DBI

instance SubL c Y => Y (Term c) where
  y = mkT @Y y

type instance SubLC c Map.Map = (SubL c Prod, SubL c Option)

instance SubL c Map.Map => Map.Map (Term c) where
  empty = mkT @Map.Map Map.empty
  alter = mkT @Map.Map Map.alter
  lookup = mkT @Map.Map Map.lookup 
  mapMap = mkT @Map.Map Map.mapMap
  singleton = mkT @Map.Map Map.singleton
  unionWith = mkT @Map.Map Map.unionWith

type instance SubLC c VTF.VectorTF = SubL c Double

instance SubL c VTF.VectorTF => VTF.VectorTF (Term c) where
  zero = mkT @VTF.VectorTF VTF.zero
  plus = mkT @VTF.VectorTF VTF.plus
  mult = mkT @VTF.VectorTF VTF.mult
  basis = mkT @VTF.VectorTF VTF.basis
  vtfMatch = mkT @VTF.VectorTF VTF.vtfMatch

type instance SubLC c Option = SubL c DBI

instance SubL c Option => Option (Term c) where
  just = mkT @Option just
  nothing = mkT @Option nothing
  optionMatch = mkT @Option optionMatch

genInstance :: Q [Dec]
genInstance =
  M.mapM gen [
    ''DBI,
    ''Double,
    ''Bool,
    ''Lang,
    ''Fix,
    ''Int,
    ''Char,
    ''Float,
    ''VTF.VectorTF,
    ''Map.Map,
    ''Bimap,
    ''Prod,
    ''IO,
    ''Unit,
    ''Option,
    ''Sum,
    ''List,
    ''Y,
    ''Dual,
    ''DiffWrapper,
    ''FreeVector]
    where
      gen n = M.return $
        InstanceD
          M.Nothing
          []
          (AppT (AppT (ConT ''SubL) (ConT ''Lang)) (ConT n))
          [ValD (VarP 'sub) (NormalB (AppE (ConE 'Sub) (ConE 'Dict))) []]
