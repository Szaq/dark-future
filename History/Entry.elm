module History.Entry exposing(EntryType(..), Model, Msg, view, information)

import Html exposing(..)
import Time

type EntryType = Speech | Information | Event

type alias Model = {date: Time.Time, text: String, entryType: EntryType}

type Msg = None

view: Model -> Html Msg
view model = div [] [text model.text]

information: String -> Model
information text = Model 0 text Information
