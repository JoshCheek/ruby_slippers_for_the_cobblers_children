import Http
import Html exposing (Html)
import Task exposing (Task)
import Json.Decode as Json exposing ((:=))
import Graphics.Element exposing (show)


type Ast
  = AstUninitialized               -- This is stupid, but the mailbox needs an initial value
  | AstNone                        -- For when there is no value
  | AstInt String                  -- value, should be an int
  | AstString String               -- value
  | AstSymbol String               -- value
  | AstSend Ast String (List Ast)  -- target, message, args
  | AstUnknown String              -- show the type, ie if we forget to parse one

parsedCode : Signal.Mailbox Ast
parsedCode = Signal.mailbox AstUninitialized

-- main = show (Json.decodeString decoder "{\"type\": \"integer\", \"value\": \"1\"}")
main = Signal.map show parsedCode.signal

port fetchCode : Task Http.Error ()
port fetchCode =
  Http.post decodeAst "http://localhost:3003" (Http.string "1.a 'b', :c, d")
    `Task.andThen` report

report : Ast -> Task x ()
report result =
  Signal.send parsedCode.address result


-- NOTE: toplevel can be null
decodeAst : Json.Decoder Ast
decodeAst =
  Json.oneOf
  [ ("type" := Json.string)
      `Json.andThen`
      \t ->
        case t of
          "integer" -> decodeInt
          "send"    -> decodeSend
          "string"  -> decodeString
          "symbol"  -> decodeSymbol
          otherwise -> decodeUnknown
  , Json.null AstNone
  -- this shouldn't ever happen, but it already has (https://github.com/elm-lang/core/issues/305), so, leaving it in
  , Json.customDecoder Json.value (\json -> (Ok <| AstUnknown (toString json)))
  ]

decodeInt     = Json.object1 AstInt     ("value"   := Json.string)
decodeUnknown = Json.object1 AstUnknown ("type"    := Json.string)
decodeSend    = Json.object3 AstSend    ("target"  := decodeAst)
                                        ("message" := Json.string)
                                        ("args"    := Json.list decodeAst)
decodeString  = Json.object1 AstString  ("value" := Json.string)
decodeSymbol  = Json.object1 AstSymbol  ("value" := Json.string)

-- An example of what we have to parse (minus locations)
-- a 1 + 2, "b", :d
--
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
