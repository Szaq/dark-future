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
            (Dict.insert 0 <| Location.Model "South Room" "Your very personal room in the south, which you like" [ ( Direction.North, 1 ) ] []) <|
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

        Item item ->
            describeItem item


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
            location.description ++ "\n\nExits: " ++ (String.join ", " (List.map (fst >> toString) location.exits))

        Nothing ->
            "No such thing"


describeItem : Item.Model -> String
describeItem item =
    "This is " ++ item.name ++ "\n\n" ++ item.description



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
