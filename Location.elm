module Location exposing (..)

import Direction exposing (..)
import Item
import Character.Functions exposing(..)
import Character.Model exposing(..)
import Character.Msg exposing(..)
import Dict
import Time


type alias LocationId =
    Int


type alias Locations =
    Dict.Dict Int LocationModel


type alias LocationModel =
    { name : String
    , description : String
    , exits : DirectionMap LocationId
    , items : List Item.Model
    , characters : List CharacterModel
    }


locationWithAddedCharacter : CharacterModel -> LocationModel -> LocationModel
locationWithAddedCharacter character location =
    { location | characters = location.characters ++ [ character ] }


locationWithRemovedCharacter : CharacterModel -> LocationModel -> LocationModel
locationWithRemovedCharacter character location =
    let
        notEqual evaluatedCharacter =
            character.id /= evaluatedCharacter.id
    in
        { location | characters = List.filter notEqual location.characters }


locationsWithMovedCharacter : CharacterId -> LocationId -> LocationId -> Locations -> Maybe (Locations)
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


locationsAfterTickInLocation: Time.Time -> LocationId -> Locations -> Locations
locationsAfterTickInLocation time id locations =
      let updatedLocation = Maybe.map (locationAfterTick time) (Dict.get id locations)

      in  Maybe.map (\location -> Dict.insert id location locations) updatedLocation
          |> Maybe.withDefault locations

locationAfterTick: Time.Time -> LocationModel -> LocationModel
locationAfterTick time location =
    let characterTick character = update (Character.Msg.Tick time) character
    in { location | characters = List.map (fst << characterTick) location.characters }


selectCharacter : CharacterId -> CharacterModel -> Maybe CharacterModel
selectCharacter id character =
    if character.id == id then
        Just character
    else
        Maybe.Nothing


characterInLocation : CharacterId -> LocationModel -> Maybe CharacterModel
characterInLocation id location =
    Maybe.oneOf <| List.map (selectCharacter id) location.characters
