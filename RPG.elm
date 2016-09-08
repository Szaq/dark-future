module RPG exposing (..)

import Html.App as App
import Html exposing (..)
import Character
import String
import Location
import Dict exposing (..)
import History
import History.Entry as HistoryEntry
import Input
import LookAt exposing(..)
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
    Model (Character.Model "Szaq" Character.Human)
        [ HistoryEntry.information "Welcome in the madness" ]
        ""
        0
        (singleton 0 <| Location.Model "Your Room" "Your very personal room, which you like" [])


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
            addInformationToHistory model <| "You went " ++ toString direction

        Command.Look at ->
            lookAt at model
            |> addInformationToHistory model



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

lookAt: LookAt -> Model -> String
lookAt at model = case at of
          Place  -> describeLocation (get model.currentLocation model.locations)
          Item item -> describeItem item

describeLocation : Maybe Location.Model -> String
describeLocation location = case location of
    Just location -> location.description ++ "\n\nExits: " ++ (String.join ", " (List.map (fst>>toString) location.exits))
    Nothing -> "No such thing"

describeItem: Item.Model -> String
describeItem item = "This is " ++ item.name ++ "\n\n" ++ item.description