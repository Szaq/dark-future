module Location exposing(Model, Id)

import Direction exposing(..)

type alias Id = Int

type alias Exit = (Direction, Id)

type alias Model = {name: String, description: String, exits: List Exit}
