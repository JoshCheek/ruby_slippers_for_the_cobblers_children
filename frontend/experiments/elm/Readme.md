Elm Architecture Tutorial
  https://github.com/evancz/elm-architecture-tutorial/
  Keep models, updates, and views independent of each other
  Some stuff with addresses that I don't really understand
  Same for contexts
  elm-reactor is pretty awesome

Reactivity
  http://elm-lang.org/guide/reactivity
  Signals   - Events that kick off your code (entry points to your code)
  Tasks     - Intent to do some Asynchronous work that can fail
              These can be chained like promises
              It looks like you can define the same method, but with a "prime" on it to have it auto-find the method and use it for error handling
  Ports     - Communicate to the outside world -- these Execute tasks,
              they seem to kick off independently of your code,
              and you have to give them mailboxes to tell them how to communicate back to it
              When you give a signal of tasks, the events kick off the port independently
  Mailboxes - An address and signal.
              Still not really comfortable with addresses.
              The address allows it to be the recipient of a message (send mailbox.address someValue)
              When this gets a message sent to it, it kicks off the signal

Grpahics.Element
  https://github.com/elm-lang/core/blob/2.1.0/src/Graphics/Element.elm

Fun BST challenges
  http://elm-lang.org/examples/binary-tree
  My solutions: https://gist.github.com/JoshCheek/74ac1126b3cc17a8df88

Testing
  http://package.elm-lang.org/packages/deadfoxygrandpa/Elm-Test/1.0.4
  https://github.com/maxsnew/IO/

Compiler errors for humans
  http://elm-lang.org/blog/compiler-errors-for-humans
  <3

Style guide
  https://gist.github.com/evancz/0a1f3717c92fe71702be

Elm Test
  http://package.elm-lang.org/packages/deadfoxygrandpa/Elm-Test/1.0.4

BST challenges
  challenge:
    http://elm-lang.org/examples/binary-tree
  my solutions:
    https://gist.github.com/JoshCheek/74ac1126b3cc17a8df88

StartApp
  A good reference for how to structure your app
  https://github.com/evancz/start-app/blob/ca78ce8902b35ecde67b14c10ca3e3c583eb97e2/src/StartApp.elm
