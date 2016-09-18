module Character.AI exposing(..)

import Character.AI.Structures exposing(..)
import Character.Structures exposing(..)

import Time exposing(..)

update: Msg -> Character.AI.Structures.Model -> Character.AI.Structures.Model
update msg model = model

defaultAI: Character.AI.Structures.Model
defaultAI =
    Character.AI.Structures.Model
      { behavior = Neutral
      , tickFunc = defaultAITick
      }

aiWithTick: (Time -> Character.AI.Structures.Model -> Character.AI.Structures.Model) -> Character.AI.Structures.Model -> Character.AI.Structures.Model
aiWithTick tickFunc model = case model of
    Model model -> Character.AI.Structures.Model {model | tickFunc = tickFunc}

defaultAITick: Time -> Character.AI.Structures.Model -> Character.AI.Structures.Model
defaultAITick time model = model
