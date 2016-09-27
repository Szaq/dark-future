module Character.Model exposing(..)

import Item
import Time
import Character.AI.Model

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


type Controller
    = ThisPlayer
    | OtherPlayer
    | AI Character.AI.Model.Model
