module Character.AI.Model exposing(..)

import Time exposing(..)

type Behavior = Friendly | Neutral | Aggresive

type Model = Model { behavior: Behavior
                   , tickFunc: Time -> Model -> Model}
