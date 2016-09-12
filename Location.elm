module Location exposing(Model, Id)

import Direction exposing(..)
import Item
type alias Id = Int

type alias Model = {name: String, description: String, exits: DirectionMap Id, items: List Item.Model}
