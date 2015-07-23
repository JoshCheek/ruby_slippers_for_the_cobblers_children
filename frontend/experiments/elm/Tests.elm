module Main where

-- I need to turn each test into a signal
-- so that it can kick off parsing through the port
-- the test will be run on the completion of the task

import Parser exposing (Ast)
import String
import ElmTest.Test exposing (test, Test, suite)
import ElmTest.Assertion exposing (assert, assertEqual)
import ElmTest.Runner.Element exposing (runDisplay)

main : Signal Graphics.Element.Element
main = Signal.map show Parser.parsedCode.signal
-- main = runDisplay tests

port doParse : Signal (Task x ())
port doParse =
  parse code `andThen` (\result -> Signal.send Parser.parseCode.signal result)

show : Ast -> Element
show ast =
  Graphics.Element.leftAligned (Text.monospace (Text.fromString (toString ast)))

assertParses : String -> String -> (Ast -> Assertion) -> Assertion
assertParses name code assertions =
  test "Parses empty file" (parse "" \parsed -> (assertEqual parsed Parser.AstNone)

tests : Test
tests = suite "Parser"
        [ assertParses "empty file" "" \ast -> (assertEqual ast Parser.AstNone)
        ]

-- testAddition =
--   test "Addition" (assertEqual (3 + 7) 10)

-- testStringLeft =
--   test "String.left" (assertEqual "a" (String.left 1 "abcdefg"))

-- testFailure =
--   test "This test should fail" (assert False)
