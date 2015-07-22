-- https://gist.githubusercontent.com/wiz/d914d2167b6008ee93fb/raw/dee6639cc65e3ffd27080f3d75781c771ee68a76/mini.elm
import Debug
import Graphics.Input as Input
import Html
import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Html.Tags (..)
import Http
import Window

-- Application state
type State = {count:Int}

initialState = {count:0}

-- Application-wide actions (that trigger state change)
data Action
    = NoOp
    | GotResult Int

-- Entry point
main : Signal Element
main = scene <~ state ~ Window.dimensions

-- "Fold-from-past" for incoming application signals
state : Signal State
state = foldp step initialState <| merges [ actions.signal
                                          , gotResult <~ fetchStuff clicky.signal
                                          ]

actions : Input.Input Action
actions = Input.input NoOp

gotResult : () -> Action
gotResult () = GotResult

-- The Magic is happening here
------------------------------

-- A channel to trigger a HTTP request.
-- Heads up! The type should provide at least two distinct values if you don't want
-- your request to fire right upon application launch. () however is perfectly fine
-- for initial query (for settings and such).
clicky : Input.Input (Maybe String)
clicky = Input.input Nothing

-- Transform a stream of requests to a stream of responses.
fetchStuff : Signal (Maybe String) -> Signal ()
fetchStuff querySource =
    let makeQuery q =
            case Debug.watch "Query" q of
                Nothing      -> Http.get ""
                Just payload -> Http.post "/stuff.json" payload

        getResult r =
            case Debug.watch "Result" r of
                _ -> ()

    in getResult <~ Http.send (lift makeQuery querySource)

-- Transform a response to a application event

-- Boring stuff
---------------

-- Update application state due to incoming event
step : Action -> State -> State
step a s = case Debug.watch "State" s of
    _ -> s

-- Elm container for rendered DOM
scene : State -> (Int, Int) -> Element
scene s (w,h) = Html.toElement w h <| view s

-- Render application state as DOM
view : State -> Html
view s = p []
    [ button [ onclick clicky.handle (always <| Just "hello there") ] [ text "click me" ]
    ]
