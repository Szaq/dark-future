module Character.AI.Functions exposing(..)

import Character.AI.Model exposing(..)
import Character.Msg exposing(..)

import Time exposing(..)

update: Msg -> Character.AI.Model.Model -> Character.AI.Model.Model
update msg model = model

defaultAI: Character.AI.Model.Model
defaultAI =
    Character.AI.Model.Model
      { behavior = Neutral
      , tickFunc = defaultAITick
      }

aiWithTick: (Time -> Character.AI.Model.Model -> Character.AI.Model.Model) -> Character.AI.Model.Model -> Character.AI.Model.Model
aiWithTick tickFunc model = case model of
    Model model -> Character.AI.Model.Model {model | tickFunc = tickFunc}

defaultAITick: Time -> Character.AI.Model.Model -> Character.AI.Model.Model
defaultAITick time model = model
