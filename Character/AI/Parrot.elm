module Character.AI.Parrot exposing(..)

import Character.AI.Structures exposing (..)
import Character.AI exposing (..)

import Time exposing(..)

parrotAI: Model
parrotAI =
    aiWithTick parrotTick defaultAI

parrotTick: Time -> Model -> Model
parrotTick time model = model
