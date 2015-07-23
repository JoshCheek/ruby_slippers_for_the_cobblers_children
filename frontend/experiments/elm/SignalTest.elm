import Debug
import Task exposing (Task)
import Graphics.Element exposing (Element, show)

type alias MyModel = (Int, String)

-- Signals should come from here and be sent to here
mailbox : Signal.Mailbox MyModel
mailbox = Signal.mailbox model

-- Update the view with each input
model : MyModel
model = (0, "")

main : Signal Element
main = Signal.map view (Signal.foldp update model input)

input : Signal MyModel
input = mailbox.signal

view : MyModel -> Element
view (count, str) =
  show ((toString count) ++ str)

update : MyModel -> MyModel -> MyModel
update (count1, str1) (count2, str2) =
  (count1 + count2, str1 ++ str2)
  -- Debug.watch "updates" (count1 + count2, str1 ++ str2)

  -- When I run it with the Debug.watch above,
  -- It blows up saying:
  --
  -- ```
  -- Cannot read property 'forEach' of undefined
  -- Open the developer console for more details.
  -- ```
  --
  -- (dev console just repeats the error)
  --
  -- I ran the debugger like this: `$ elm-reactor` in this file's dir,
  -- then go to http://localhost:8000/SignalTest.elm?debug




-- Here, I try getting it to generate each input.
-- Ie this represents my test suite, where the tests need to make HTTP requests,
-- which must be done via a port,
-- which must either be hard-coded for the port, or sent via a Signal.
-- So I try turning them into a list of signals to be sent to the mailbox above,
-- The thought being that each test can become a signal so that it can feed into the port,
-- and when the response comes back, the main process can then run the test.
--
-- I can't figure out how to get around the fact that I can't run a task without either having it hard-coded
-- into the port definition, or having it be generated from a signal, but I can't make a signal without
-- sending messages to a mailbox, which requires a task. Chicken/egg situation.
-- I looked all through Signal.elm, and didn't see anything with a signature that created a Signal without one already existing.
--
-- But it only gets the first value, because Signal.mergeMany uses Signal.merge https://github.com/elm-lang/core/blob/37af7decaeb743641d0be2aebc0a0002b5d71d68/src/Signal.elm#L193
-- which turns them all into one single signal. https://github.com/elm-lang/core/blob/37af7decaeb743641d0be2aebc0a0002b5d71d68/src/Signal.elm#L164-165
-- So I think they all come in at the same time, and it only keeps the first
port emitAll : Signal (Task x ())
port emitAll = Signal.map emitNextModel modelSignals

emitNextModel : MyModel -> Task x ()
emitNextModel model = Signal.send mailbox.address model

modelSignals : Signal MyModel
modelSignals = Signal.mergeMany (List.map Signal.constant modelValues)

modelValues : List MyModel
modelValues = [(1,"a"), (2, "b"), (3, "b")]
