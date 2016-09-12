module Character.AI exposing(..) 

type Behavior = Friendly | Neutral | Aggresive

type alias Model = {behavior: Behavior} 