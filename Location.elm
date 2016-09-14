module Location exposing (..)

import Direction exposing (..)
import Item
import Character
import Dict


type alias Id =
    Int


type alias Locations =
    Dict.Dict Int Model


type alias Model =
    { name : String
    , description : String
    , exits : DirectionMap Id
    , items : List Item.Model
    , characters : List Character.Model
    }


locationWithAddedCharacter : Character.Model -> Model -> Model
locationWithAddedCharacter character location =
    { location | characters = location.characters ++ [ character ] }


locationWithRemovedCharacter : Character.Model -> Model -> Model
locationWithRemovedCharacter character location =
    let
        notEqual evaluatedCharacter =
            character.id /= evaluatedCharacter.id
    in
        { location | characters = List.filter notEqual location.characters }


locationsWithMovedCharacter : Character.Id -> Id -> Id -> Locations -> Maybe (Locations)
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


selectCharacter : Character.Id -> Character.Model -> Maybe Character.Model
selectCharacter id character =
    if character.id == id then
        Just character
    else
        Nothing


characterInLocation : Character.Id -> Model -> Maybe Character.Model
characterInLocation id location =
    Maybe.oneOf <| List.map (selectCharacter id) location.characters
