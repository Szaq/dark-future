module Command exposing(Command(..), Direction(..), LookAt(..))

import Item

type Direction = North | South | East | West | NorthEast | SouthEast | NorthWest | SouthWest

type LookAt = Place | Item Item.ItemId

type Command = Go Direction |Look  LookAt
