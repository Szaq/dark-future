module Character exposing (..)

import Character.Structures exposing(..)

update : Msg -> Model -> ( Model, OutMsg )
update msg model =
    case msg of
      Said who loudness what -> (model, Character.Structures.Nothing)
      Tick newTime -> case model.controller of
        AI ai -> (model, Character.Structures.Nothing )
        _     -> (model, Character.Structures.Nothing)
