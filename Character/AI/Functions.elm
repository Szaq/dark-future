module Character.AI.Functions exposing(..)

import Character.AI.Model exposing(..)
import Character.Msg exposing(..)

import Time exposing(..)

update: Msg -> AIModel -> AIModel
update msg model = model

defaultAI: AIModel
defaultAI =
    AIModel
      { behavior = Neutral
      , tickFunc = defaultAITick
      }

aiWithTick: (Time -> AIModel -> AIModel) -> AIModel -> AIModel
aiWithTick tickFunc model = case model of
    AIModel model -> AIModel {model | tickFunc = tickFunc}

defaultAITick: Time -> AIModel -> AIModel
defaultAITick time model = model
