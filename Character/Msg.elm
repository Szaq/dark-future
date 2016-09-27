module Character.Msg exposing(..)

import Time
import Character.Model exposing(..)


type OutMsg
    = Nothing
    | Say (Maybe Model) Loudness String
    | Pick String
    | Drop String
    | Go String


type Msg
  = Said Model Loudness String
  | Tick Time.Time
