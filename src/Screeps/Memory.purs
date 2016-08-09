module Screeps.Memory where

import Prelude
import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Argonaut.Parser (jsonParser)
import Data.Argonaut.Printer (printJson)
import Data.Either (Either)
import Control.Monad.Eff (Eff)

import Screeps.Types (MEMORY)
import Screeps.FFI (runThisEffFn0, runThisEffFn1, unsafeGetFieldEff, unsafeSetFieldEff, unsafeDeleteFieldEff)

foreign import data MemoryGlobal :: *
foreign import memoryGlobal :: MemoryGlobal

foreign import data RawMemoryGlobal :: *
foreign import rawMemoryGlobal :: RawMemoryGlobal

get :: forall a e. (DecodeJson a) => String -> Eff ( memory :: MEMORY | e ) (Either String a)
get key = decodeJson <$> unsafeGetFieldEff key memoryGlobal

set :: forall a e. (EncodeJson a) => String -> a -> Eff ( memory :: MEMORY | e ) Unit
set key val = unsafeSetFieldEff key memoryGlobal (encodeJson val)

delete :: forall e. String -> Eff ( memory :: MEMORY | e ) Unit
delete key = unsafeDeleteFieldEff key memoryGlobal

getRaw :: forall a e. (DecodeJson a) => Eff ( memory :: MEMORY | e) (Either String a)
getRaw = fromJson <$> runThisEffFn0 "get" rawMemoryGlobal

getRaw' :: forall e. Eff ( memory :: MEMORY | e) String
getRaw' = runThisEffFn0 "get" rawMemoryGlobal

setRaw :: forall a e. (EncodeJson a) => a -> Eff ( memory :: MEMORY | e) Unit
setRaw memory = runThisEffFn1 "set" rawMemoryGlobal (toJson memory)

setRaw' :: forall e. String -> Eff ( memory :: MEMORY | e) Unit
setRaw' = runThisEffFn1 "set" rawMemoryGlobal

fromJson :: forall a. (DecodeJson a) => String -> (Either String a)
fromJson jsonStr = jsonParser jsonStr >>= decodeJson

toJson :: forall a. (EncodeJson a) => a -> String
toJson = printJson <<< encodeJson