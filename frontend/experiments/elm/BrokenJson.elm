import Json.Decode exposing (..)
import Graphics.Element

main            = Graphics.Element.show parsed
parsed          = decodeString decodeByKind "{\"kind\":\"parent\",\"value\":{\"kind\":\"child\",\"value\":1}}"
decodeByKind    = "kind" := string `andThen` chooseDecoder
chooseDecoder k = if k == "child" then decodeChild else decodeParent
decodeChild     = "value" := int
decodeParent    = "value" := decodeByKind
