module Character exposing (..)

import Character.Model exposing(..)
import Character.Msg exposing(..)

update : Msg -> Model -> ( Model, OutMsg )
update msg model =
    case msg of
      Said who loudness what -> (model, Character.Msg.Nothing)
      Tick newTime -> case model.controller of
        AI ai -> (model, Character.Msg.Nothing )
        _     -> (model, Character.Msg.Nothing)
