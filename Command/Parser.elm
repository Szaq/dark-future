module Command.Parser exposing(parseInput)

import Direction exposing(..)
import LookAt exposing(..) 
import Command exposing(..)
import Regex exposing (..)
import Maybe exposing (..)
import String

{-| Parses input string into command -}
parseInput: String -> Maybe Command
parseInput input = oneOf [parseGo input,
                          parseLookAt input]

findMatch: String -> String -> Maybe Match
findMatch regexString inputString = find All (regexString |> regex |> caseInsensitive) inputString |> List.head

findAndExtractMatch: String -> String -> Maybe String
findAndExtractMatch regexString inputString = case findMatch regexString inputString of
                                               Just match -> case List.head match.submatches of
                                                              Just submatch -> submatch
                                                              Nothing -> Nothing
                                               Nothing -> Nothing


parseGo: String -> Maybe Command.Command
parseGo input = findAndExtractMatch "^go (.*)" input
                `andThen` parseDirection
                |> map Go

parseLookAt: String -> Maybe Command.Command
parseLookAt input = findMatch "^look" input
                    `andThen` (\_ -> Just <| Look Place)

parseDirection: String -> Maybe Direction
parseDirection input = case String.toLower input of
                        "north" -> Just North
                        "south" -> Just South
                        "east" -> Just East
                        "west" -> Just West
                        "north-east" -> Just NorthEast
                        "north-west" -> Just NorthWest
                        "south-east" -> Just SouthEast
                        "south-west" -> Just SouthWest
                        _ -> Nothing
