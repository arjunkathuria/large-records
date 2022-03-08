{-# LANGUAGE ConstraintKinds       #-}
{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DuplicateRecordFields #-} -- TODO: Improve error message without this
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE GADTs                 #-}
{-# LANGUAGE KindSignatures        #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE UndecidableInstances  #-}

-- TODO: This should compile without adding any manual language extensions

{-# OPTIONS_GHC -fplugin=Data.Record.Plugin #-}

-- | Record definitions for "Test.Record.Sanity.RDP.SplitModule"
--
-- See "Test.Record.Sanity.RDP.SplitModule" for details.
--
-- TODO: Export list (should the plugin help with this..?)
module Test.Record.Sanity.RDP.SplitModule.RecordDef where

{-# ANN type R1 largeRecordStrict #-}
data R1 = MkR1 { r1_x :: Int, r1_y :: Bool }
  deriving (Show, Eq)

{-# ANN type R2 largeRecordStrict #-}
data R2 = MkR2 { a :: Int, b :: Bool }
  deriving (Show, Eq)

{-# ANN type R3 largeRecordStrict #-}
data R3 = MkR3 { a :: Int, b :: Char }
  deriving (Show, Eq)

{-# ANN type R4_WithLR largeRecordStrict #-}
data R4_WithLR = MkR4_WithLR { r4_withLR_x :: Int, r4_withLR_y :: R5_WithLR }
  deriving (Show, Eq)

{-# ANN type R5_WithLR largeRecordStrict #-}
data R5_WithLR = MkR5_WithLR { r5_withLR_x :: Char, r5_withLR_y :: Double }
  deriving (Show, Eq)


