Ruby Object Model Viewer
========================

This will eventually be a Ruby Interpreter that runs in the browser,
displaying its internal state visually, in order to help learners
understnd what is available, and how Ruby works.
It's still a giant WIP.


High Level Description / Plan
-----------------------------

User will be on a webpage with a text editor, e.g. http://104.131.24.233/josh/mocking-io,
there will be an "Object Model" button (similar to the "Run" button on some of the code samples).
When they click it, it takes their code, sends it to the server for parsing.
A JSON ast comes back. It instantiates an interpreter and hands the ast to the interpreter.
It creates a canvas or something, and iterates over the interpreter's instructions,
drawing a visual representation of the object model at each relevant point.

Eventually, would be nice to get it interactive, so a user can step through the program,
possibly also in reverse, click an object to see its ivars, click the ivar to follow
the pointer to the target. Peruse the stack, etc.

Would be nice to add games to it in order to make it more compelling for learners to
interact with it and develop an intuition for how Ruby works, what it does, how thier
code manipulates this.


Prioritized TODO
----------------

* Interpreter: switch fillFrom to use `EvaluationState`, and get rid of the `workToDo` stack.
  This will allow us to see intermediate steps in the algorithms the interpreter is doing (e.g. method lookup).
* Interpreter: have all instantiation go through one spot so we have access to the correct classes and such.
* Interpreter: `ruby.RubyInterpreter` is redundant, just rename it to `ruby.Interpreter`?

Unprioritized TODO
------------------

* Interpreter
  * push more on that acceptance test.
* Parser
  * Check out `ruby_parser`, looks much smaller than Parser, so might be easier to bootstrap,
    and Ryan was really nice to me at RubyConf while Peter was kinda dismissive of this project.
    Big question: Does it provide file info (e.g. this expression came from file x.rb, line 5, chars 9-15)
  * Make sure I'm handling [all AST nodes](https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md)
    Once this is done, make sure the interpreter does, too
  * 5.8e+07 <-- make sure ruby parser thing can handle this (for object model)
* Figure out which license is best



Future TODO / To think about
----------------------------

* Parser
  * Bootstraping
    * If we could do this, then we wouldn't need the server
    * Would need to implement the C-level Rack lib, which looks to be about 800 LOC, and then just parse the runtime
    * Would need some way to represent the file system.
    * Deps for Parser: (parser, racc, ast)
    * Deps for RubyParser: (ruby_parser, racc, sexp_processor), these look much smaller
    * Might be worth including the original Ruby source code with the JSON ast. e.g.

      ```json
      {"files": [{"name": "gems/some_gem/lib/some_gem.rb",
                  "body": "class SomeGem\n  def some_method\n  end\nend"}
                ],
       "ast":   "what we're currently serving for ast, but with file info that references the provided files"
      }
      ```
    * Alternatively, if we could fake out the file system, like FakeFS, we could straight ship the file system with it.
    * Can they host it locally? Would get around the need to mock the file system
  * Choose more minified keys since certain tasks could lead to massive ASTs (e.g. parsing the parser)
* Interpreter
  * Would be cool if we could get [RubySpec](https://github.com/rubyspec/rubyspec) to run against it.
  * Do we need a `Symbol` class, or can we use Haxe strings? Might be a use case for abstract classes.
  * Figure out how to work with it as data structures (interfaces/static extensions?)
* User Interface
  * Figure out best way to render
    * Flash (e.g. some of these Haxe libs)
    * D3
    * Canvas
    * WebGl
  * Ability to see what they're interested in without getting spammed (e.g. "show me only code executing in my file")
  * Talk to someone w/ UX experience, find an intuitive but comprehensive interface to navigate
* General
  * Ability to display in the code editor what the browser is currently interpreting (e.g. highlighting current expression)
  * integrate with moi (prob rename that, since everyone gets it suggested to them, apparently)
  * Can we save a user's file? e.g. so they can share with a friend, or submit a bug report?
  * Any way to integrate with something insane like Rails?
  * Write content that uses it to illustrate the lesson (e.g. in Moi)


List of notes / links that might be helpful
-------------------------------------------
* Interpreter
  * List of [Rubinius bytecodes](http://rubini.us/doc/en/virtual-machine/instructions/)
* Parser
* Front end / Usability
  * Game dev [reading group](https://groups.google.com/forum/#!topic/game-maker-study-group/TwGr9AQ_eQk) for [Challenges for Game Designers](http://www.amazon.com/dp/158450580X)
    led by JEG2. Hoping to use some of these ideas to make this fun for students to work in.
  * Short summary of best points in the [Design of Every Day Things](http://drhaswell.com/index.php/2012/08/book-review-the-design-of-everyday-things/)
  * The [7 stages of action](https://en.wikipedia.org/wiki/Seven_stages_of_action)
* Other tools for (inspiration)
  * [Omniscient Debugger](http://www.lambdacs.com/debugger/) Holy shit, this doesn't even sound all that hard!
* [Thoughts and links](http://lighttable.com/2014/05/16/pain-we-forgot/) about tools like these, from authors of Light Table.
* [Not sure](http://pchiusano.blogspot.com/2013/05/the-future-of-software-end-of-apps-and.html),
  but looks like it has some interesting philisophical implications regarding how we think about software (ie thinking of it not as an app or machine)
* UX for [Bing search](http://blogs.msdn.com/b/visualstudio/archive/2014/02/17/introducing-bing-code-search-for-c.aspx)
* [Example Centric programming](http://www.subtext-lang.org/OOPSLA04.pdf)
* [Debug mode is the only mode](http://gbracha.blogspot.com/2012/11/debug-mode-is-only-mode.html) discusses Bret Victor, some good looking links
* [Local state is harmful](http://scattered-thoughts.net/blog/2014/02/17/local-state-is-harmful/) haven't figured out its point, but I imagine this conclusion is  drawn from a deeper principle
* [Wolfram Deployment API](https://www.wolfram.com/universal-deployment-system/) apparently they are doing crazy cool shit, worth checking out to get ideas... and possibly use, if it's as awesome as people imply with their hype
* [Video Building an interpreter](http://www.confreaks.com/videos/2685-gogaruco2013-let-s-write-an-interpreter) (30 min) Great talk by Ryan Davis about buliding an interpreter
* [Video about parsing expressions in Ruby](http://confreaks.com/videos/582) Recommended by Ryan Davis in the above talk
* [Video about type inferrence](https://www.youtube.com/watch?v=AHAONhPchKA) (possibly dealing with Soft Typing) by Loren Segal, he recommended it at RubyConf 2014
* [Javascript programming game](http://alexnisnevich.github.io/untrusted/) A take on what it might be like to use games to teach programming
