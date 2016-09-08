module History exposing(Model, Msg(..), update, view, initialModel)

import Html exposing(..)
import Html.App as App
import History.Entry as Entry

type alias Model = List Entry.Model

type Msg = Entry Entry.Msg | Add Entry.Model

update: Msg -> Model -> Model
update msg model = case msg of
  Add entry ->  model ++ [entry]
  Entry a -> model

view: Model -> Html Msg
view model = div [] <| List.map (Entry.view >> App.map Entry) model

initialModel: Model
initialModel = []
