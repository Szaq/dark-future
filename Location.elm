module Location exposing (..)

import Direction exposing (..)
import Item
import Character
import Character.Model exposing(..)
import Character.Msg exposing(..)
import Dict
import Time


type alias Id =
    Int


type alias Locations =
    Dict.Dict Int Model


type alias Model =
    { name : String
    , description : String
    , exits : DirectionMap Id
    , items : List Item.Model
    , characters : List Character.Model.Model
    }


locationWithAddedCharacter : Character.Model.Model -> Model -> Model
locationWithAddedCharacter character location =
    { location | characters = location.characters ++ [ character ] }


locationWithRemovedCharacter : Character.Model.Model -> Model -> Model
locationWithRemovedCharacter character location =
    let
        notEqual evaluatedCharacter =
            character.id /= evaluatedCharacter.id
    in
        { location | characters = List.filter notEqual location.characters }


locationsWithMovedCharacter : Character.Model.Id -> Id -> Id -> Locations -> Maybe (Locations)
locationsWithMovedCharacter characterId oldLocationId newLocationId locations =
    let
        oldLocation =
            Dict.get oldLocationId locations

        newLocation =
            Dict.get newLocationId locations

        player =
            oldLocation `Maybe.andThen` characterInLocation characterId

        updatedOldLocation =
            Maybe.map2 locationWithRemovedCharacter player oldLocation

        updatedNewLocation =
            Maybe.map2 locationWithAddedCharacter player newLocation
    in
        Maybe.map2
            (\new old ->
                Dict.insert newLocationId new locations
                    |> Dict.insert oldLocationId old
            )
            updatedNewLocation
            updatedOldLocation


locationsAfterTickInLocation: Time.Time -> Id -> Locations -> Locations
locationsAfterTickInLocation time id locations =
      let updatedLocation = Maybe.map (locationAfterTick time) (Dict.get id locations)

      in  Maybe.map (\location -> Dict.insert id location locations) updatedLocation
          |> Maybe.withDefault locations

locationAfterTick: Time.Time -> Model -> Model
locationAfterTick time location =
    let characterTick character = Character.update (Character.Msg.Tick time) character
    in { location | characters = List.map (fst << characterTick) location.characters }


selectCharacter : Character.Model.Id -> Character.Model.Model -> Maybe Character.Model.Model
selectCharacter id character =
    if character.id == id then
        Just character
    else
        Maybe.Nothing


characterInLocation : Character.Model.Id -> Model -> Maybe Character.Model.Model
characterInLocation id location =
    Maybe.oneOf <| List.map (selectCharacter id) location.characters
