module Character.AI.Model exposing(..)

import Time exposing(..)

type Behavior = Friendly | Neutral | Aggresive

type AIModel = AIModel { behavior: Behavior
                   , tickFunc: Time -> AIModel -> AIModel}
