module Input exposing(Model, Msg(..), OutMsg(..), update, view)

import Html exposing(input, button, text, div, Html)
import Html.Events exposing(onInput, onClick)


type alias Model = String

type Msg = ChangeText String | SubmitClicked
type OutMsg = Nothing | Submit String

update: Msg -> Model -> (Model, OutMsg)
update msg model = case msg of
  ChangeText text -> (text, Nothing)
  SubmitClicked -> ("", Submit model)

view: Model -> Html Msg
view model = div []
              [input [onInput ChangeText][]
              ,button [onClick SubmitClicked][text "Submit"]
              ]
