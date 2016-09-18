module Character.Structures exposing(..)

import Item
import Time
import Character.AI.Structures

type Race
    = Human
    | Elf
    | Dwarf
    | Orc
    | Animal String

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
    | Tick Time.Time


type Controller
    = ThisPlayer
    | OtherPlayer
    | AI Character.AI.Structures.Model


type OutMsg
    = Nothing
    | Say (Maybe Model) Loudness String
    | Pick String
    | Drop String
    | Go String
