module Character.Functions exposing (..)

import Character.Model exposing(..)
import Character.Msg as Msg exposing(..)

update : Msg -> CharacterModel -> ( CharacterModel, OutMsg )
update msg model =
    case msg of
      Said who loudness what -> (model, Msg.Nothing)
      Tick newTime -> case model.controller of
        AI ai -> (model, Msg.Nothing )
        _     -> (model, Msg.Nothing)
