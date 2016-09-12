module Input exposing(Model, Msg(..), OutMsg(..), update, view)

import Html exposing(input, button, text, div, Html)
import Html.Events exposing(onInput, onClick, on)
import Json.Decode as Json


type alias Model = String

type Msg = ChangeText String | SubmitClicked
type OutMsg = Nothing | Submit String

update: Msg -> Model -> (Model, OutMsg)
update msg model = case msg of
  ChangeText text -> (text, Nothing)
  SubmitClicked -> ("", Submit model)

is13 : Int -> Result String ()
is13 code =
  if code == 13 then Ok () else Err "not the right key code"

handleKeyPress : Json.Decoder Msg
handleKeyPress =
  Json.map (always SubmitClicked) (Json.customDecoder Html.Events.keyCode is13)

view: Model -> Html Msg
view model = div []
              [input [onInput ChangeText, on "keypress" handleKeyPress][]
              ,button [onClick SubmitClicked][text "Submit"]
              ]
