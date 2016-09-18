module Character.AI.Structures exposing(..)

import Time exposing(..)

type Behavior = Friendly | Neutral | Aggresive

type Model = Model { behavior: Behavior
                   , tickFunc: Time -> Model -> Model}
