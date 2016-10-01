module Character.AI.Parrot exposing(..)

import Character.AI.Model exposing (..)
import Character.AI.Functions exposing (..)

import Time exposing(..)

parrotAI: AIModel
parrotAI =
    aiWithTick parrotTick defaultAI

parrotTick: Time -> AIModel -> AIModel
parrotTick time model = model
