Ruby Object Model Viewer
========================

This will eventually be a Ruby Interpreter that runs in the browser,
displaying its internal state visually, in order to help learners
understnd what is available, and how Ruby works.
It's still a giant WIP.


Prioritized TODO
----------------

* Clean up all these random files
* Get a license


Unprioritized TODO
------------------
* have all instantiation go through one spot so we have access to the correct classes and such.
* switch fillFrom to use an enum indicating the type of return value is an expression, or some state in a larger algorithm
* experiment with object model represented as records instead of classes (see experiments dir)
* push more on that acceptance test.
* Check out `ruby_parser`, looks much smaller than Parser, so might be easier to bootstrap,
  and Ryan was really nice to me at RubyConf while Peter was kinda dismissive of this project.


Shit I haven't looked at in a long time that needs to be cleaned
----------------------------------------------------------------

If interpreting from the ast,
we still need a stream of actions that we can show to the user.
So perhaps this model:

Thought about the below: Should we just walk the entire program at once,
eagerly, rather than lazily, as needed? If we do this, we can
identify the entire program at once, then it's just a matter of
applying/unapplying the instructions (two stacks)

* `next_instruction`
  * If the instructions list is not empty,
    remove the first instruciton,
    perform its forward,
    set its backward,
    place it at he front of the history list.
  * Elsif the instructions are empty,
    ask the ast-walker for the next set of instructions,
    replace the instructions list with these instructions,
    call `next_instruction`
  * Elsif the ast-walker has finished
    The program is done.
* `prev_instruction`
  * If the history list is empty, do nothing.
  * If the history list is not empty,
    remove the first item from it,
    Perform its backward,
    place it at the front of the instruciton list.
