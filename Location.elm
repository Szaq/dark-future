module Location exposing (..)

import Direction exposing (..)
import Item
import Character
import Dict


type alias Id =
    Int


type alias Model =
    { name : String
    , description : String
    , exits : DirectionMap Id
    , items : List Item.Model
    , characters : List Character.Model 
    }

locationsWithMovedCharacter: Character.Id -> Id -> Id -> Dict.Dict Int Model -> Maybe (Dict.Dict Int Model)
locationsWithMovedCharacter characterId oldLocationId newLocationId locations = 
            let oldLocation = 
                    Dict.get oldLocationId locations

                newLocation = 
                    Dict.get newLocationId locations

                player = 
                    oldLocation `Maybe.andThen` characterInLocation characterId

                selectCharacter character =
                    character.id == characterId 

                updatedOldLocation = 
                    Maybe.map (\location -> 
                                {location 
                                    | characters = List.filter selectCharacter location.characters}) oldLocation

                updatedNewLocation =
                    Maybe.map2 (\location player ->
                                             Just {location 
                                                     | characters =  location.characters ++ [player]}) newLocation player
                    |> Maybe.withDefault Nothing
                     

                in Maybe.map2 
                    (\new old -> Dict.insert newLocationId new locations 
                                |>  Dict.insert oldLocationId old) updatedNewLocation updatedOldLocation
            
selectCharacter: Character.Id -> Character.Model -> Maybe Character.Model
selectCharacter id character =  if character.id == id then
                                    Just character
                                    else 
                                    Nothing
characterInLocation: Character.Id -> Model -> Maybe Character.Model
characterInLocation id location = Maybe.oneOf <| List.map (selectCharacter id) location.characters
