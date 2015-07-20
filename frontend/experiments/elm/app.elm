import Html exposing (div, button, text)
import Html.Events exposing (onClick)
import StartApp

import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)


main =
  StartApp.start { model = model, view = view, update = update }

model = 0

view address model =
  div []
    [ button [ onClick address Decrement ] [ Html.text "-" ]
    , div [] [ Html.text (toString model) ]
    , button [ onClick address Increment ] [ Html.text "+" ]
    , Html.fromElement (collage 300 300 (circleOfCircles ++ spheres ++ hexagons ++ [text]))
    ]

type Action = Increment | Decrement

update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1

-- text
text : Form
text = rotate (degrees 20) (toForm (show "Any element can go here!"))

-- hexagons
hexagons : List Form
hexagons =
  List.map (move (-80, 80))
    [ hexagon red
    , hexagon blue
        |> rotate (degrees 30)
        |> scale 1.15
    , (ngon 6 33)
        |> filled (rgb 50 150 200)
        |> rotate (degrees 30)
    ]

hexagon : Color -> Form
hexagon clr =
  outlined (solid clr) (ngon 6 40)

-- circle of circles
circleOfCircles : List Form
circleOfCircles =
  [ move (-55,-55) (gradient grad1 (circle 100))
  , move ( 40, 85) (gradient grad2 (circle 100))
  , move ( 50,-10) (gradient grad3 (circle 100))
  , move (-10, 50) (gradient grad4 (circle 100))
  ]

shape : Int -> Form
shape n =
  let angle = degrees (30 * toFloat n)
  in  circle 10
      |> filled (hsl angle 0.7 0.5)
      |> move (45 * cos angle, 45 * sin angle)


-- spheres
spheres : List Form
spheres = List.map shape [0..11]

grad1 : Gradient
grad1 =
  radial (0,0) 50 (0,10) 90
    [ (  0, rgb  244 242 1)
    , (0.8, rgb  228 199 0)
    , (  1, rgba 228 199 0 0)
    ]

grad2 : Gradient
grad2 =
  radial (0,0) 15 (7,-5) 40
    [ (  0, rgb  0 201 255)
    , (0.8, rgb  0 181 226)
    , (  1, rgba 0 181 226 0)
    ]

grad3 : Gradient
grad3 =
  radial (0,0) 20 (7,-15) 50
    [ (   0, rgb  255 95 152)
    , (0.75, rgb  255 1 136)
    , (   1, rgba 255 1 136 0)
    ]

grad4 : Gradient
grad4 =
  radial (0,0) 10 (7,-5) 30
    [ (  0, rgb  167 211 12)
    , (0.9, rgb  1 159 98)
    , (  1, rgba 1 159 98 0)
    ]
