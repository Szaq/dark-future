module RPG exposing (..)

import Html.App as App
import Html exposing (..)
import Character
import String
import Location
import Direction exposing (..)
import Dict exposing (..)
import History
import History.Entry as HistoryEntry
import Input
import LookAt exposing (..)
import Item
import Command
import Command.Parser


main : Program Never
main =
    App.beginnerProgram { model = model, view = view, update = update }


type alias Model =
    { player : Character.Model
    , history : History.Model
    , input : Input.Model
    , currentLocation : Location.Id
    , locations : Dict Location.Id Location.Model
    }


model : Model
model =
    let
        locations =
            (Dict.insert 0 <| Location.Model "South Room" "Your very personal room in the south, which you like" [ ( Direction.North, 1 ) ] [ Item.Model "Candle" "Ordinary candle making light where is darkness" ]) <|
                (Dict.insert 1 <| Location.Model "North Room" "Your very personal room in the north, which you like" [ ( Direction.South, 0 ) ] []) <|
                    Dict.empty

        player =
            Character.Model "Szaq" Character.Human []

        initialHistory =
            [ HistoryEntry.information "Welcome in the madness" ]
    in
        Model player initialHistory "" 0 locations


type Msg
    = History History.Msg
    | Input Input.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        Input inputMsg ->
            handleInput inputMsg model

        History historyMsg ->
            { model | history = History.update historyMsg model.history }


view : Model -> Html Msg
view model =
    div []
        [ text <| "Welcome " ++ model.player.name ++ " , it seems you're " ++ toString model.player.race
        , App.map History <| History.view model.history
        , App.map Input <| Input.view model.input
        ]



------------------------------------------------------------------
------------------------- Input handling -------------------------
------------------------------------------------------------------


handleInput : Input.Msg -> Model -> Model
handleInput msg model =
    let
        ( modelInputAfterUpdate, outMsg ) =
            Input.update msg model.input

        modelAfterInput =
            { model | input = modelInputAfterUpdate }
    in
        case outMsg of
            Input.Submit text ->
                let
                    command =
                        Command.Parser.parseInput text
                in
                    Maybe.map2 handleCommand command (Just modelAfterInput)
                        |> Maybe.withDefault modelAfterInput

            Input.Nothing ->
                modelAfterInput


handleCommand : Command.Command -> Model -> Model
handleCommand command model =
    case command of
        Command.Go direction ->
            goTo direction model

        Command.Look at ->
            lookAt at model
                |> addInformationToHistory model



------------------------------------------------------------------
---------------------------Command Handling ----------------------
------------------------------------------------------------------


lookAt : LookAt -> Model -> String
lookAt at model =
    case at of
        Place ->
            describeLocation (Dict.get model.currentLocation model.locations)

        Item name ->
            let
                item =
                    Maybe.oneOf [ itemInCurrentLocation name model
                                , itemInPlayerInventory name model ]
            in
                Maybe.map describeItem item |> Maybe.withDefault "Oh sorry. No such thing"


goTo : Direction -> Model -> Model
goTo direction model =
    case exitInCurrentLocation direction model of
        Just id ->
            let
                modelWithNewLocation =
                    { model | currentLocation = id }

                location =
                    currentLocation modelWithNewLocation

                description =
                    describeLocation location
            in
                addInformationToHistory modelWithNewLocation description

        Nothing ->
            model



------------------------------------------------------------------
---------------------------Output Utils  -------------------------
------------------------------------------------------------------


addInformationToHistory : Model -> String -> Model
addInformationToHistory model text =
    let
        historyEntry =
            HistoryEntry.information text
    in
        { model | history = History.update (History.Add historyEntry) model.history }


describeLocation : Maybe Location.Model -> String
describeLocation location =
    case location of
        Just location ->
            let
                desc =
                    location.description

                itemsDesc =
                    String.join ", " <| List.map .name location.items

                exitsDesc =
                    String.join ", " <| List.map (toString << fst) location.exits
            in
                desc
                    ++ "\nItems: "
                    ++ itemsDesc
                    ++ "\nExits: "
                    ++ exitsDesc

        Nothing ->
            "No such thing"


describeItem : Item.Model -> String
describeItem item =
    "This is " ++ item.name ++ "\n" ++ item.description



------------------------------------------------------------------
--------------------------- Model Helpers ------------------------
------------------------------------------------------------------


{-| Get current location from model
-}
currentLocation : Model -> Maybe Location.Model
currentLocation model =
    Dict.get model.currentLocation model.locations


{-| Get an exist in specified direction from current location from model
-}
exitInCurrentLocation : Direction -> Model -> Maybe Location.Id
exitInCurrentLocation direction model =
    case currentLocation model of
        Just location ->
            Direction.get direction location.exits

        Nothing ->
            Nothing

{-| Select item by name from items list-}
selectItem : String -> List Item.Model -> Maybe Item.Model
selectItem name items =
    let
        selectItem name item =
            if (String.toLower item.name) == (String.toLower name) then
                Just item
            else
                Nothing
    in
        Maybe.oneOf <| List.map (selectItem name) items



{-| Get item by name from a location
-}
itemInLocation : String -> Location.Model -> Maybe Item.Model
itemInLocation name location =
    selectItem name location.items


{-| Get item by name from a current location
-}
itemInCurrentLocation : String -> Model -> Maybe Item.Model
itemInCurrentLocation name model =
    let
        location =
            currentLocation model
    in
        location `Maybe.andThen` itemInLocation name

{-| Get item by name from some character's inventory
-}
itemInCharacterInventory : String -> Character.Model -> Maybe Item.Model
itemInCharacterInventory name character =
    selectItem name character.items

{-| Get item by name from player's inventory
-}
itemInPlayerInventory : String -> Model -> Maybe Item.Model
itemInPlayerInventory name model =
    itemInCharacterInventory name model.player
