Ruby Slippers For The Cobbler's Children
========================================

### Vision (why)

To teach learners to think about Ruby in its underlying model rather than syntactic patterns they've memorized.
Allow them to reason about their code in terms of how it affects the object model.

They say ["The Cobbler's children have no shoes"](https://www.quora.com/Is-the-cobblers-children-have-no-shoes-a-real-phenomena-If-so-what-causes-it).
I experienced this in my own education and continue to experience it as I continue to learn.
And now, as an instructor at [The Turing School of Software and Design](http://turing.io/),
I see it with my students.
The opacity of the tools, the cryptic or nonexistent feedback,
the oversight of communicating the model or providing examples,
the slow feedback loops, the systems that don't allow for feedback.

We are barefoot and our children are barefoot, and it is bullshit.
This project is part of my attempt to address the issue for Ruby.

You might also be interested in [Seeing Is Believing](https://github.com/JoshCheek/seeing_is_believing),
another tool I created and use daily. It's aim wasn't quite as ambitious,
but its method is similar: provide a labratory to perform experiments with
a maximum of feedback and a minimum of effort.

[Here](https://vimeo.com/99541348)
is an exerpt of what it looks like when I teach the object model in class.

### Goal (what)

* A Ruby interpreter with a **visual/interactive interface**.
* Explore the object graph by clicking around it,
  following variables, and watching the algorithms execute
  (e.g. understand inheritance by watching it look up a method).
* Experiment by submitting your own code,
  seeing how it is interpreted,
  tweaking it and observing the difference.
* This is not intended to run production code,
  it will always choose transparency over optimization.

### Implementation (How)

* This will eventually be a Ruby Interpreter that attempts to expose all
  of its state and algorithms as data structures that can be reflected on.
  Once this is accomplished, it becomes a matter of providing a user-interface
  to draw the visualization and allow interactive exploration.
* It will run in the browser to reduce the setup and know-how required to try it.
  This is important because I think it's significantly impacted adoption of
  [SeeingIsBelieving](https://github.com/JoshCheek/seeing_is_believing),
  even though it's one of the most effective tools a learner could use
  (to be fair, that depends on whether the learner learns via hypothesizing
  and experimenting).
* I might also try turning it into a command-line tool with Atom Shell.
  This has value because once a learner sees it as a viable tool,
  they can run it locally, without leaving their development environment.
  Which in turn allows them to run it against code that has more than one
  file (the web interface will likely be a single Ace editor, thus it can
  handle only one file). Of course, that's exponentially more ambitious than
  this project is at present.

Running
-------

* Install parser dependencies
  * You will need Ruby. I'll leave that to you O.o
  * `cd parser`
  * `bundle` if this fails, you may need to first `gem install bundler`
    if this fails, probably your Ruby is installed at a global level or something.
  * `cd ..`
  * `rake parser:test`
* Start the parser server `$ rake parser:server:start`
* Hit it with curl `curl --silent localhost:3003 -d 'puts "hello, world"'`
* I like to pile the output of that through [jq](https://stedolan.github.io/jq/) for readability
  ```ruby
  $ curl --silent localhost:3003 -d 'puts "hello, world"' | jq .
  {
    "type": "send",
    "target": null,
    "message": "puts",
    "args": [
      {
        "type": "string",
        "value": "hello, world",
        "location": {
          "filename": "(eval)",
          "begin": 5,
          "end": 19
        }
      }
    ],
    "location": {
      "filename": "(eval)",
      "begin": 0,
      "end": 19
    }
  }
  ```

Parser Notes
------------

* Here is a list of [all AST nodes](https://github.com/whitequark/parser/blob/master/doc/AST_FORMAT.md),
  We need to make sure we can handle all of them.
* [Video about parsing expressions in Ruby](http://confreaks.com/videos/582)
  Recommended by Ryan Davis
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
* We could restrict syntax at the parser level (e.g. add a challenge where you are only allowed to use a subset of features
  so that student has to learn alternate ways to handle a situation, and syntactically enforce the constraint.)

Interpreter Notes
-----------------

* Could apply interesting constraints at the ast level (e.g. "no classes", "only loca vars", etc),
  which would require them to explore other ways of doing things that they normally wouldn't be exposed to.
* Potentially relevant
  * List of [Rubinius bytecodes](http://rubini.us/doc/en/virtual-machine/instructions/)
  * [RubySpec](https://github.com/rubyspec/rubyspec), Brian's work to formally define Ruby's behaviour.
    Looks like [this](https://github.com/ruby/ruby/blob/1026907467ea3d5441e1bfa95f5f37b431a684f3/spec/default.mspec) is integration for MRI.
  * [I think this is where Ruby's specification starts](https://github.com/ruby/ruby/blob/trunk/test/runner.rb)
    as in you can presumably do something like `ruby test/runner.rb` decided to go look at it to see if it seemed viable as a test suite
    (as in "doesn't depend on a C implementation"),
    and it looks like it should be runnable. Depending on how serious I get,
    probably worth hitting that one and RubySpec simultaneously for a bit.
  * [Official Ruby Spec](http://www.iso.org/iso/iso_catalogue/catalogue_tc/catalogue_detail.htm?csnumber=59579)
    I haven't looked into it yet. Got the link from the [rebuttal](https://gist.github.com/nateberkopec/11dbcf0ee7f2c08450ea)
    of Brian's post. UPDATE: it costs $200 and is for Ruby 1.8 YorickPeterse has an excellent rebuttal of why it's bad for RubySpec to die.
    It's really annoying that MRI sees itself as "whatever the fuck we happened to do is what Ruby is".

* Inspiration
  * [Omniscient Debugger](http://www.lambdacs.com/debugger/) Holy shit, this doesn't even sound all that hard!
  * [Not sure](http://pchiusano.blogspot.com/2013/05/the-future-of-software-end-of-apps-and.html),
    but looks like it has some interesting philisophical implications regarding how we think about software
    (ie thinking of it not as an app or machine)
  * [Debug mode is the only mode](http://gbracha.blogspot.com/2012/11/debug-mode-is-only-mode.html)
    discusses Bret Victor, some good looking links
  * [Video Building an interpreter](http://www.confreaks.com/videos/2685-gogaruco2013-let-s-write-an-interpreter)
    (30 min) Great talk by Ryan Davis about buliding an interpreter
  * [Video about type inferrence](https://www.youtube.com/watch?v=AHAONhPchKA)
    (possibly dealing with Soft Typing) by Loren Segal, he recommended it at RubyConf 2014
  * [Time Travel For Debugging at Rubyconf](http://confreaks.com/videos/4818-RubyConf2014-a-partial-multiverse-model-of-time-travel-for-debugging)
    "With only a few restrictions and side-effects we will learn how to construct and use a time machine."

Frontend Notes
--------------


* Potential drawing libraries / platforms
  * Drawing on the canvas directly
    * [2D Grapphics with the HTML Canvas](https://www.youtube.com/playlist?list=PLD3FC8B16E1D7C4B0&feature=view_all)
  * Drawing in Three.js https://twitter.com/josh_cheek/status/571232192874942466
  * WebGL
  * Elm
  * paper.js
  * mathbox2 - http://acko.net/files/pres/siggraph-2014-bof/online.html
  * [Local state is harmful](http://scattered-thoughts.net/blog/2014/02/17/local-state-is-harmful/)
    haven't figured out its point, but I imagine this conclusion is drawn from a deeper principle
* Embedding into Miniature Octo Ironman
  * Ability to display in the code editor what the browser is currently interpreting
    (e.g. highlighting current expression)
  * Either highlight in editor or draw independently
    ```javascript
    // Highlighting. note that it's placing the range in the wrong place. Not sure why
    // might get them to the right place: https://github.com/ajaxorg/ace/issues/2130#issuecomment-54609425
    // might be necessary to keep them in right place if user edits/scrolls (probably turn this off during its execution, though)
    editor.getValue(); // returns textual code to be sent to interpreter
    ace.Range = ace.require('ace/range'); // makes the range code available
    r = new ace.Range(4, 2, 4, 6); // creates a Range object on line 4, cols 2-6
    s = editor.getSession(); // returns an EditSession
    sr = r.toScreenRange(s);  // maps the underlying range to a range on the screen
    n  = s.addMarker(sr, 'test-marker', 'MYMARKERTYPE', false) // adds the screen range to the editing session
    $('.test-marker').css({background: 'green'}); // shitty way to add a background (gets overwritten when redrawn, I think
    s.removeMarker(n); // remove the marker
    ```
  * Human explanation of what it's doing and why.
    e.g. "in order to define a class, we need to create a constant, create this instance, etc..."
* Getting better at the domain
  * Ability to see what they're interested in without getting spammed
    (e.g. "show me only code executing in my file")
  * [codeschool.org course on game programming](http://codeschool.org/game-programming/)
    includes info like how to work with 2D and 3D structures, and example game codebases.
  * Short summary of best points in the [Design of Every Day Things](http://drhaswell.com/index.php/2012/08/book-review-the-design-of-everyday-things/)
  * The [7 stages of action](https://en.wikipedia.org/wiki/Seven_stages_of_action)
  * [Thoughts and links](http://lighttable.com/2014/05/16/pain-we-forgot/) about tools like these, from authors of Light Table.
  * [Example Centric programming](http://www.subtext-lang.org/OOPSLA04.pdf)
* Other cool tools that could serve as inspiration
  * UX for [Bing search](http://blogs.msdn.com/b/visualstudio/archive/2014/02/17/introducing-bing-code-search-for-c.aspx)
  * [Wolfram Deployment API](https://www.wolfram.com/universal-deployment-system/)
    apparently they are doing crazy cool shit, worth checking out to get ideas... and possibly use,
    if it's as awesome as people imply with their hype
  * [Javascript programming game](http://alexnisnevich.github.io/untrusted/)
    A take on what it might be like to use games to teach programming
  * [Codingame](http://www.codingame.com/ide/754417c54da4822e560181e9ab49be8d02ca97) Michael sent me

Game ideas
----------

* Game dev [reading group](https://groups.google.com/forum/#!topic/game-maker-study-group/TwGr9AQ_eQk) for [Challenges for Game Designers](http://www.amazon.com/dp/158450580X)
  led by JEG2. Hoping to use some of these ideas to make this fun for students to work in.
* Challenges
  * Constraints
    * Not able to use the mouse (just have to figure out how to disable the mouse in the Ace editor)
* Trace This Variable
  * ie "@a was set in #initialize, from local var "a", that came from param the param that came from X.new(1)"
* "bridge the gap"
  show an object model,
  user writes code to get to it
* Simon
  * watch interpreter trace the path of execution
  * you reproduce it
* Be the ruby interpreter
  * you are given some code,
  * some controls, then you use the controls to specify what the interpreter would do
  * (remove the keyboard syntax as a barrier to the object model)
