import Http
import Html exposing (Html)
import Task exposing (Task)
import Json.Decode as Json exposing ((:=))
import Graphics.Element exposing (show)


type Ast
  = None
  | AstInt String -- should be an int
  | AstUnknown String

parsedCode : Signal.Mailbox Ast
parsedCode = Signal.mailbox None

-- main = show (Json.decodeString decoder "{\"type\": \"integer\", \"value\": \"1\"}")
main = Signal.map show parsedCode.signal

port fetchCode : Task Http.Error ()
port fetchCode =
  Http.post decoder "http://localhost:3003" (Http.string "123")
    `Task.andThen` report

report : Ast -> Task x ()
report result =
  Signal.send parsedCode.address result


decoder : Json.Decoder Ast
decoder =
  ("type" := Json.string) `Json.andThen` decodeAst


decodeAst : String -> Json.Decoder Ast
decodeAst t =
  case t of
    "integer" -> Json.object1 AstInt     ("value" := Json.string)
    otherwise -> Json.object1 AstUnknown ("type"  := Json.string)


-- decodeInt : Json.Decoder Ast
-- decodeInt =
  -- Json.object1 AstInt ("value" := Json.int)


-- decodeUnknown : Json.Decoder Ast
-- decodeUnknown =
  -- Json.object1 AstUnknown ("type" := Json.string)


-- An example of what we have to parse (minus locations)

-- { "type": "send",
--   "target": null,
--   "message": "a",
--   "args": [
--     { "type": "send",
--       "target": { "type": "integer", "value": "1" },
--       "message": "+",
--       "args": [{ "type": "integer", "value": "2" }],
--     },
--     { "type": "string", "value": "b" },
--     { "type": "symbol", "value": "d" }
--   ],
-- }
