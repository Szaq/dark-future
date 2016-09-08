module Character exposing(Model, Race(..))

type Race = Human | Elf | Dwarf | Orc

type alias Model = {name: String, race: Race}
