module Character.Model exposing(..)

import Item
import Character.AI.Model exposing (..)

type Race
    = Human
    | Elf
    | Dwarf
    | Orc
    | Animal String

type alias CharacterId = String

type alias CharacterModel =
    { id: CharacterId
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
    | AI AIModel
