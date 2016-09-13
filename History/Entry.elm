module History.Entry exposing (EntryType(..), Model, Msg, view, information)

import Html exposing (..)
import Time
import String exposing (..)


type EntryType
    = Speech
    | Information
    | Event


type alias Model =
    { date : Time.Time, text : String, entryType : EntryType }


type Msg
    = None


view : Model -> Html Msg
view model =
    let
        displayLine line =
            [ div [] [ text line ], br [][] ]

        displayLines lines =
            List.map displayLine lines |> List.concat

        lines =
            split "\n" model.text
    in
        div [] (displayLines lines)


information : String -> Model
information text =
    Model 0 text Information
