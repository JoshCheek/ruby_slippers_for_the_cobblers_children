import Http
import Html exposing (Html)
import Task exposing (Task)
import Json.Decode as Json exposing ((:=), value)
import Graphics.Element exposing (Element, show)
import String exposing (toInt)
import Text


type Ast
  = AstUninitialized               -- This is stupid, but the mailbox needs an initial value
  | AstNone                        -- For when there is no value
  | AstInt Int                     -- value
  | AstString String               -- value
  | AstSymbol String               -- value
  | AstSend Ast String (List Ast)  -- target, message, args
  | AstUnknown String              -- show the type, ie if we forget to parse one

toString : Ast -> String
toString ast = case ast of
  AstUninitialized            -> "Uninitialized"
  AstNone                     -> "null"
  AstInt n                    -> Basics.toString n
  AstString str               -> Basics.toString str
  AstSymbol sym               -> ":" ++ (Basics.toString sym)
  AstSend target message args -> (toString target) ++ "." ++ message ++ "(" ++ (String.join ", " (List.map toString args)) ++ ")"
  AstUnknown typ              -> "Unknown: " ++ typ

show : Ast -> Element
show ast =
  Graphics.Element.leftAligned (Text.monospace (Text.fromString (toString ast)))


parsedCode : Signal.Mailbox Ast
parsedCode = Signal.mailbox AstUninitialized


main : Signal Graphics.Element.Element
main = Signal.map show parsedCode.signal


port fetchCode : Task Http.Error ()
port fetchCode =
  Http.post decodeAst "http://localhost:3003" (Http.string "1.a 'b', :c, d")
    `Task.andThen` report


report : Ast -> Task x ()
report result =
  Signal.send parsedCode.address result


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
  , Json.customDecoder Json.value (\json -> (Ok <| AstUnknown (Basics.toString json)))
  ]

decodeUnknown = Json.object1 AstUnknown ("type"   := Json.string)
decodeString  = Json.object1 AstString  ("value"  := Json.string)
decodeSymbol  = Json.object1 AstSymbol  ("value"  := Json.string)

decodeInt =
  let toAstInt s = case (toInt s) of Ok i -> AstInt i
                                     _    -> AstInt 0 -- shouldn't ever happen
  in Json.object1 toAstInt ("value" := Json.string)

decodeSend = Json.object3 AstSend
                          ("target" := decodeAst)
                          ("message" := Json.string)
                          ("args" := Json.list decodeAst)
