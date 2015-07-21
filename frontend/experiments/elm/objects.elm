import Color exposing (rgb, rgba, radial, Gradient)
import Graphics.Collage exposing (collage, LineStyle, Form, scale, move, circle, gradient)
import Graphics.Element exposing (Element)

import Text exposing (fromString)
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
  { name     : String
  , targetId : ObjectId
  }

type alias WorldState =
  { allObjects : List ObjectState }

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
  in WorldState [leftObject, rightObject]

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
update (time, arrow) {allObjects} =
  let pressedLeft         = (arrow.x ==  1)
      pressedRight        = (arrow.x == -1)
      leftObj             = case (List.head allObjects) of
                              Just obj  -> obj
                              otherwise -> buildModel 1 True
      rightObj            = case (List.head <| List.drop 1 allObjects) of
                             Just obj  -> obj
                             otherwise -> buildModel 2 False
  in if | pressedLeft  -> WorldState [(iterate <| activate   leftObj), (iterate <| deactivate rightObj)]
        | pressedRight -> WorldState [(iterate <| deactivate leftObj), (iterate <| activate   rightObj)]
        | otherwise    -> WorldState [(iterate leftObj),               (iterate rightObj)]

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
view {allObjects} =
  let viewObjectsById = List.map (\obj -> (obj.objectId, (viewObject obj.currentState))) allObjects
      viewObjects     = List.map snd viewObjectsById
      getIvars obj    = List.map (\ivar -> (obj, ivar)) obj.ivars
      ivarsByObj      = List.foldl (++) [] (List.map getIvars allObjects)
      viewIvars       = List.foldl (++) [] <| List.map (\(obj, ivar) -> viewIvar obj.currentState ivar viewObjectsById) ivarsByObj
      viewElements    = viewObjects ++ viewIvars
  in  collage 600 400 viewElements

viewIvar : DisplayState -> InstanceVariable -> List (ObjectId, Form) -> List Form
viewIvar display ivar viewObjectsById =
  let targetObject = findObject ivar.targetId viewObjectsById
      varName      = Text.fromString ivar.name
                     |> Text.color Color.brown
                     |> Text.bold
                     |> Graphics.Collage.text
                     |> Graphics.Collage.scale 2
                     |> move (display.x, display.y)
                     |> Graphics.Collage.scale display.scale
      arrowPath    = Graphics.Collage.path [(display.x, display.y), (targetObject.x, targetObject.y)]
      defaultStyle = Graphics.Collage.defaultLine
      arrowStyle   = { defaultStyle
                     | cap   <- Graphics.Collage.Round
                     , color <- Color.brown
                     , width <- 5 * display.scale
                     }
      arrow        = Graphics.Collage.traced arrowStyle arrowPath
  in  [varName, arrow]

viewObject : DisplayState -> Form
viewObject {x, y, scale} =
  gradient grad (circle 100)
  |> move  (x, y)
  |> Graphics.Collage.scale scale

grad : Gradient
grad =
  let highlight  = rgb  220 240 255
      baseColour = rgb  150 150 230
      shadow     = rgba  50  70 100 0
  in radial (0, 0) 40 (0, 10) 90 [(0, highlight), (0.8, baseColour), (1, shadow)]

findObject : ObjectId -> List (ObjectId, Form) -> Form
findObject targetId ((crntId, form)::rest) =
  if | crntId == targetId -> form
     | otherwise -> findObject targetId rest
