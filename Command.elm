module Command exposing(Command(..))

import Direction exposing(..)
import LookAt exposing(..)

type Command = Go Direction |Look  LookAt
