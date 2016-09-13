module Character exposing (Model, Race(..), Loudness(..), Controller(..), OutMsg(..), Id)

import Item
import Character.AI


type Race
    = Human
    | Elf
    | Dwarf
    | Orc

type alias Id = String

type alias Model =
    { id: Id
    , name : String
    , race : Race
    , items : List Item.Model
    , controller : Controller
    }


type Loudness
    = Whisper
    | Speech
    | Scream


type Msg
    = Said Model Loudness String


type Controller
    = ThisPlayer
    | OtherPlayer
    | AI Character.AI.Model


type OutMsg
    = Nothing
    | Say (Maybe Model) Loudness String
    | Pick String
    | Drop String
    | Go String


update : Msg -> Model -> ( Model, OutMsg )
update msg model =
    ( model, Nothing )
