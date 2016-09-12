module Character exposing(Model, Race(..))

import Item

type Race = Human | Elf | Dwarf | Orc

type alias Model = {name: String, race: Race, items: List Item.Model}

type Loudness = Whisper | Speech | Scream 

type Action = Say Model Loudness String
              | Pick Item.Model
              | Drop Item.Model
              | Use Item.Model (Maybe Item.Model)
