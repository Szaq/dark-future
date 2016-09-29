module Character.AI.Parrot exposing(..)

import Character.AI.Model exposing (..)
import Character.AI.Functions exposing (..)

import Time exposing(..)

parrotAI: Model
parrotAI =
    aiWithTick parrotTick defaultAI

parrotTick: Time -> Model -> Model
parrotTick time model = model
