{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- | Fresh name generation
module Data.Record.Anon.Internal.Plugin.Source.FreshT (
    -- * Monad definition
    FreshT -- opaque
  , runFreshT
  , runFreshHsc
    -- * Generate fresh names
  , fresh
  , freshVar
  ) where

import Control.Monad.Reader
import Data.IORef

import Data.Record.Anon.Internal.Plugin.Source.GhcShim

{-------------------------------------------------------------------------------
  Monad definition
-------------------------------------------------------------------------------}

-- | Fresh name generation
newtype FreshT m a = WrapFreshT {
      unwrapNamingT :: ReaderT (IORef NameCache) m a
    }
  deriving (Functor, Applicative, Monad)

instance MonadTrans FreshT where
  lift = WrapFreshT . lift

runFreshT :: IORef NameCache -> FreshT m a -> m a
runFreshT ncVar = flip runReaderT ncVar . unwrapNamingT

runFreshHsc :: FreshT Hsc a -> Hsc a
runFreshHsc ma = do
    env <- getHscEnv
    runFreshT (hsc_NC env) ma

{-------------------------------------------------------------------------------
  Key features of FreshT
-------------------------------------------------------------------------------}

fresh :: MonadIO m => SrcSpan -> RdrName -> FreshT m RdrName
fresh l name = WrapFreshT $ do
    ncVar <- ask
    liftIO $ atomicModifyIORef ncVar aux
  where
    aux :: NameCache -> (NameCache, RdrName)
    aux nc = (
          nc { nsUniqs = us }
        , Exact $ mkInternalName newUniq (newOccName (rdrNameOcc name)) l
        )
      where
        (newUniq, us) = takeUniqFromSupply (nsUniqs nc)

    -- Even when we generate fresh names, ghc can still complain about name
    -- shadowing, because this check only considers the 'OccName', not the
    -- unique. We therefore prefix the name with an underscore to avoid the
    -- warning.
    newOccName :: OccName -> OccName
    newOccName n = mkOccName (occNameSpace n) . ("_" ++) $ occNameString n

{-------------------------------------------------------------------------------
  Derived convenience functions
-------------------------------------------------------------------------------}

freshVar :: MonadIO m => SrcSpan -> String -> FreshT m RdrName
freshVar l = fresh l . mkRdrUnqual . mkVarOcc
