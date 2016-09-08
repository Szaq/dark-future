module Location exposing(Model, Id)

type alias Id = Int

type alias Model = {name: String, description: String, exits: List Id}
