module RPG exposing (..)

import Html.App as App
import Platform.Cmd
import Html exposing (..)
import Character.Model
import Character.AI.Parrot exposing(..)
import String
import Location exposing (..)
import Direction exposing (..)
import Dict exposing (..)
import Time exposing(..)
import History
import History.Entry as HistoryEntry
import Input
import LookAt exposing (..)
import Item

import Command
import Command.Parser


main : Program Never
main =
    App.program  { init = init, update = update, subscriptions = subscriptions, view = view }


type alias Model =
    { playerId : (Location.Id, Character.Model.Id)
    , history : History.Model
    , input : Input.Model
    , locations : Dict Location.Id Location.Model
    }


init : (Model, Cmd Msg)
init =
    let
        player =
            Character.Model.Model "24242-2342342-2342342-32" "Szaq" Character.Model.Human [] Character.Model.ThisPlayer

        parrot =
            Character.Model.Model "24242-2342342-2342342-11" "Parrot" (Character.Model.Animal "Parrot") [] (Character.Model.AI parrotAI)

        locations =
            (Dict.insert 0 <| Location.Model "South Room" "Your very personal room in the south, which you like" [ ( Direction.North, 1 ) ] [ Item.Model "Candle" "Ordinary candle making light where is darkness" ] [player, parrot]) <|
                (Dict.insert 1 <| Location.Model "North Room" "Your very personal room in the north, which you like" [ ( Direction.South, 0 ) ] [] []) <|
                    Dict.empty



        initialHistory =
            [ HistoryEntry.information "Welcome in the madness" ]
    in
        (Model (0, "24242-2342342-2342342-32") initialHistory "" locations, Cmd.none)


type Msg
    = History History.Msg
    | Input Input.Msg
    | Tick Time


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Input inputMsg ->
            (handleInput inputMsg model, Cmd.none)

        History historyMsg ->
            ({ model | history = History.update historyMsg model.history }, Cmd.none)

        Tick newTime -> ({model | locations = locationsAfterTickInLocation newTime (fst model.playerId) model.locations}, Cmd.none)


view : Model -> Html Msg
view model = let player = currentPlayer model
                 playerRace = player |> Maybe.map (.race >> toString) |> Maybe.withDefault "--Unknown--"
                 playerName = player |> Maybe.map .name |> Maybe.withDefault "--Unknown--"
            in
                div []
                    [ text <| "Welcome " ++ playerName ++ " , it seems you're " ++ playerRace
                    , App.map History <| History.view model.history
                    , App.map Input <| Input.view model.input
                    ]


subscriptions: Model -> Sub Msg
subscriptions model = Time.every second Tick

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
            describeLocation (currentLocation model)

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
        Just newLocationId ->
            let
                playerId =
                    snd model.playerId

                oldLocationId =
                    fst model.playerId

                updatedLocations = locationsWithMovedCharacter playerId oldLocationId newLocationId model.locations

                modelWithNewLocation =
                    Maybe.map (\updatedLocations -> { model | playerId = (newLocationId, playerId), locations = updatedLocations }) updatedLocations

                description =
                    describeLocation (modelWithNewLocation `Maybe.andThen` currentLocation)
            in
                Maybe.map (\modelWithNewLocation -> addInformationToHistory modelWithNewLocation description) modelWithNewLocation
                |> Maybe.withDefault (addInformationToHistory model "You can't go there")

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

                charactersDesc =
                    String.join ", " <| List.map .name location.characters

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
--------------------------- Player Helpers ------------------------
------------------------------------------------------------------

currentPlayer: Model -> Maybe Character.Model.Model
currentPlayer model = let
                         location = Dict.get (fst model.playerId) model.locations
                         in
                         location `Maybe.andThen` (characterInLocation <| snd model.playerId)


------------------------------------------------------------------
--------------------------- Location Helpers ------------------------
------------------------------------------------------------------


{-| Get current location from model
-}
currentLocation : Model -> Maybe Location.Model
currentLocation model =
    Dict.get (fst model.playerId) model.locations


------------------------------------------------------------------
--------------------------- Exit Helpers ------------------------
------------------------------------------------------------------


{-| Get an exist in specified direction from current location from model
-}
exitInCurrentLocation : Direction -> Model -> Maybe Location.Id
exitInCurrentLocation direction model =
    case currentLocation model of
        Just location ->
            Direction.get direction location.exits

        Nothing ->
            Nothing


------------------------------------------------------------------
--------------------------- Items Helpers ------------------------
------------------------------------------------------------------


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
itemInCharacterInventory : String -> Character.Model.Model -> Maybe Item.Model
itemInCharacterInventory name character =
    selectItem name character.items

{-| Get item by name from player's inventory
-}
itemInPlayerInventory : String -> Model -> Maybe Item.Model
itemInPlayerInventory name model =
    currentPlayer model `Maybe.andThen` itemInCharacterInventory name
