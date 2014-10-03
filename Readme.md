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
