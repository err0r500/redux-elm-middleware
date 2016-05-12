port module Reducer exposing (Model, Msg, init, update, subscriptions)

import Redux
import Task exposing (..)
import Process
import Time exposing (..)
import Maybe exposing (Maybe)


port increment : (Maybe Int -> msg) -> Sub msg



-- port asyncIncrement : (Maybe Int -> msg) -> Sub msg


port decrement : (Maybe Int -> msg) -> Sub msg


port changeCount : (Payload -> msg) -> Sub msg


clock : Sub Msg
clock =
    Time.every second TickTock


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ decrement <| always Decrement
        , increment <| always Increment
          -- , asyncIncrement AsyncIncrement
        , changeCount ChangeCount
        , clock
        ]



-- MODEL


init : Int -> ( Model, Cmd Msg )
init value =
    ( { value = value, count = 1, tickTock = "TICK" }, Cmd.none )


type alias Model =
    { value : Int
    , count : Int
    , tickTock : String
    }


type alias Payload =
    Int



-- ACTIONS


type Msg
    = NoOp
    | TickTock Time
    | Increment
    | Decrement
      -- | AsyncIncrement
    | ChangeCount Payload



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    Redux.reducer out
        <| case action of
            Increment ->
                ( { model | value = model.value + model.count }, Cmd.none )

            Decrement ->
                ( { model | value = model.value - model.count }, Cmd.none )

            -- AsyncIncrement ->
            -- ( model, asyncIncTask model.count )
            ChangeCount payload ->
                ( { model | count = payload }, Cmd.none )

            TickTock _ ->
                (case model.tickTock of
                    "TICK" ->
                        ( { model | tickTock = "TOCK" }, Cmd.none )

                    "TOCK" ->
                        ( { model | tickTock = "TICK" }, Cmd.none )

                    _ ->
                        ( model, Cmd.none )
                )

            NoOp ->
                ( model, Cmd.none )


main =
    Redux.program
        { init = init 0
        , update = update
        , subscriptions = subscriptions
        }



-- OUTBOUND PORTS
-- out is needed for redux-elm-middleware


port out : Model -> Cmd msg
