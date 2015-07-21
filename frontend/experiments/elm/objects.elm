import Color exposing (rgb, rgba, radial, Gradient)
import Graphics.Collage exposing (collage, Form, scale, move, circle, gradient)
import Graphics.Element exposing (Element)

import Keyboard
import Signal exposing (foldp)
import Time exposing (..)

-- types

type alias DisplayState =
  { x     : Float
  , y     : Float
  , scale : Float
  }

type alias ObjectId = Int

type alias ObjectState =
  { objectId      : ObjectId
  , active        : Bool
  , currentState  : DisplayState
  , activeState   : DisplayState
  , inactiveState : DisplayState
  , transitions   : List DisplayState
  , ivars         : List InstanceVariable
  }

type alias InstanceVariable =
  { name   : String
  , target : ObjectId
  }

type alias WorldState =
  { leftObj  : ObjectState
  , rightObj : ObjectState
  }

type alias Arrow =
  { x : Int
  , y : Int
  }

-- wiring

main : Signal Element
main = Signal.map view (Signal.foldp update model input)

input : Signal (Time, Arrow)
input = let delta = fps 25
        in  Signal.sampleOn delta (Signal.map2 (,) delta Keyboard.arrows)

model : WorldState
model =
  let leftObject  = buildModel 1 True
                      |> addIvar "@other" rightObject.objectId
      rightObject = buildModel 2 False
  in WorldState leftObject rightObject

buildModel : ObjectId -> Bool -> ObjectState
buildModel objectId isActive =
  let multiplier    = if isActive then -1 else 1
      currentState  = if isActive then activeState else inactiveState
      activeState   = (DisplayState (multiplier * 50 )   0  2.00)
      inactiveState = (DisplayState (multiplier * 200) 100  0.50)
      transitions   = []
      ivars         = []
  in ObjectState objectId isActive currentState activeState inactiveState transitions ivars

addIvar : String -> ObjectId -> ObjectState -> ObjectState
addIvar name toObjId containingObj =
  { containingObj | ivars <- containingObj.ivars ++ [InstanceVariable name toObjId] }

-- logic

update : (Time, Arrow) -> WorldState -> WorldState
update (time, arrow) {leftObj, rightObj} =
  let pressedLeft         = (arrow.x ==  1)
      pressedRight        = (arrow.x == -1)
  in if | pressedLeft  -> WorldState (iterate <| activate   leftObj) (iterate <| deactivate rightObj)
        | pressedRight -> WorldState (iterate <| deactivate leftObj) (iterate <| activate   rightObj)
        | otherwise    -> WorldState (iterate leftObj)               (iterate rightObj)

iterate : ObjectState -> ObjectState
iterate state =
  let newTransitions  = List.drop 1 state.transitions
      newDisplayState = case (List.head state.transitions) of
                          Just dstate -> dstate
                          otherwise   -> state.currentState
  in { state | currentState <- newDisplayState, transitions <- newTransitions }


activate : ObjectState -> ObjectState
activate state =
  let transitions = if | state.active -> state.transitions
                       | otherwise    -> transitionsTo state.currentState state.activeState state.transitions
  in { state | active <- True, transitions <- transitions }

deactivate : ObjectState -> ObjectState
deactivate state =
  let transitions = if | state.active -> transitionsTo state.currentState state.inactiveState state.transitions
                       | otherwise    -> state.transitions
  in { state | active <- False, transitions <- transitions }

transitionsTo : DisplayState -> DisplayState -> List DisplayState -> List DisplayState
transitionsTo from to transitions =
  let numTransitions = 10 - (toFloat <| List.length transitions)
      xAmount        = (to.x - from.x) / numTransitions
      yAmount        = (to.y - from.y) / numTransitions
      scaleAmount    = (to.scale - from.scale) / numTransitions
      slice n        = DisplayState (from.x     + (xAmount     * n))
                                    (from.y     + (yAmount     * n))
                                    (from.scale + (scaleAmount * n))
  in List.map slice [1..numTransitions]

-- view

view : WorldState -> Element
view {leftObj, rightObj} =
  let leftSphere  = rObject leftObj.currentState
      rightSphere = rObject rightObj.currentState
  in  collage 600 400 [leftSphere, rightSphere]

rObject : DisplayState -> Form
rObject {x, y, scale} =
  gradient grad (circle 100)
  |> move  (x, y)
  |> Graphics.Collage.scale scale

grad : Gradient
grad =
  let highlight  = rgb  220 240 255
      baseColour = rgb  150 150 230
      shadow     = rgba  50  70 100 0
  in radial (0, 0) 40 (0, 10) 90 [(0, highlight), (0.8, baseColour), (1, shadow)]
