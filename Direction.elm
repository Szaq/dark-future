module Direction exposing (..)

type Direction = North | South | East | West | NorthEast | SouthEast | NorthWest | SouthWest

type alias DirectionMap a  = List (Direction, a)

empty: DirectionMap a
empty = []

get: Direction -> DirectionMap a -> Maybe a
get direction directionMap = let select item = if (fst item) == direction
                                                then Just <| snd item
                                                else Nothing
                              in
                                Maybe.oneOf <| List.map select directionMap

insert: Direction -> a -> DirectionMap a -> DirectionMap a
insert dir value directionMap = directionMap ++ [(dir, value)]
