The Interpreter
===============

Written in [Haxe](http://haxe.org/),
this will render into JavaScript or Flash
and be executed in the browser,
so it can interpret a user's code.

To run the tests
----------------

* First start the parser server: `$ rake parser:server:start`
* Then run the tests: `rake interpreter:test`

Some Ruby testing notes
-----------------------

* [RubySpec](https://github.com/rubyspec/rubyspec), Brian's work to formally define Ruby's behaviour.
  Looks like [this](https://github.com/ruby/ruby/blob/1026907467ea3d5441e1bfa95f5f37b431a684f3/spec/default.mspec) is integration for MRI.
* [Brian gives up on RubySpec](http://rubini.us/2014/12/31/matz-s-ruby-developers-don-t-use-rubyspec/) I got pretty frustrated with MRI after reading this (tweets like "MRI is the Internet Explorer of Ruby")
* [Charlie Nutter tells me I'm wrong](https://twitter.com/headius/status/550405187853352960) makes arguments decent enough for me to stop angrily demonizing MRI,
  but Ruby still needs a formal spec, it's harmful to Ruby to think of MRI as the definition of Ruby as it conflates an implementation to a specification,
  causing leaked implementation details to become canon, which severely restricts what other implementations can do. ...but then again,
  Charlie has put a shit ton of effort into JRuby, and he's apparently on the Ruby core team now, so he definitely knows what he's talking about better than I do,
  especially in this domain. But still, I'd like to hear him address those criticisms specifically,
  rather than addressing why he doesn't think RubySpec is a good enough specification for Ruby ...which, if I read the underlying intonations correctly, amounted to disliking Brian.
  Which is fine, but someone needs to sit down and say "this is what Ruby is". Thoughtfully and thoroughly, with considerations to the implications of those decisions.
* [http://tonyarcieri.com/volapuk-a-cautionary-tale-for-any-language-community](Volapük: A Cautionary Tale for Any Language Community)
  Charles Oliver Nutter tweeted this (apparently Tony Arcierti wrote it).
  Basically says there was a popular Esperanto-like language with tons of followers, and it died b/c one of its main contributors forked it,
  making it not a universal language. Says that forking languages is harmful. Questionable logic b/c that language's selling point was its candidacy as a single universal language.
  This is not true of Ruby, for example. Also, Rbx isn't deviating by choice, they're deviating b/c there's no fucking specification of what Ruby is,
  and they tried to make one, but it wasn't adopted and nothing reasonable has been suggested in its place. IOW, Rbx would be an implementation of Ruby,
  if there was something concrete to implement. It's basically on MRI for seeing it like "Ruby is whatever we happen to have done, bugs, implementation details, and all".
  That's the real harm, I still think it's exactly like everyone considering HTML and HTTP to be whatever IE happened to have done back in the day when it owned the browser market.
  Remember how shitty that was? See how many awesome browser options we have now that there's a real standard? Given that there isn't a Ruby standard,
  I think it makes total sense to let go of the pain, restrictions, and tedium of trying to mimic Ruby, and instead focus on what cool things Rbx can bring to the table.
  Now, to be fair, he's spent years of his life implementing a Ruby (probably more years on JRuby than I've even been programming), so in many ways, he would know better than I.
  But he is now apparently on the Ruby core team, which makes me less confident in his objectivity. I feel like JRuby has felt a lot of the same pains as Rbx over the years.
* [I think this is where Ruby's specification starts](https://github.com/ruby/ruby/blob/trunk/test/runner.rb)
  as in you can presumably do something like `ruby test/runner.rb` decided to go look at it to see if it seemed viable as a test suite (as in "doesn't depend on a C implementation"),
  and it looks like it should be runnable. Depending on how serious I get, probably worth hitting that one and RubySpec simultaneously for a bit.
* [Official Ruby Spec](http://www.iso.org/iso/iso_catalogue/catalogue_tc/catalogue_detail.htm?csnumber=59579)
  I haven't looked into it yet. Got the link from the [rebuttal](https://gist.github.com/nateberkopec/11dbcf0ee7f2c08450ea)
  of Brian's post. UPDATE: it costs $200 and is for Ruby 1.8 YorickPeterse has an excellent rebuttal of why it's bad for RubySpec to die.
  It's really annoying that MRI sees itself as "whatever the fuck we happened to do is what Ruby is".

Some haxe notes
---------------

* [Download Haxe](http://haxe.org/download/)
* Docs
  * [intro](http://haxe.org/documentation/introduction/) for high-level understanding.
  * [Manual](http://haxe.org/manual/) very very well done manual
  * [api](http://api.haxe.org/) reasonably documented, still worth cloning the source code.
  * [My examples](https://gist.github.com/JoshCheek/a3ba5325df017f6e346e) Just lots of playing with stuff. Maybe it should move into this repo's experiments.
* Given the file `HelloWorld.hx`
  * Compile to js with

    ```sh
    $ haxe -main HelloWorld -js HelloWorld.js
    $ node HelloWorld.js
    ```
  * Compile to Java with

    ```sh
    $ haxe -main HelloWorld -java HelloWorldJava
    $ cd HelloWorldJava
    $ java -cp ./HelloWorld.jar haxe.root.HelloWorld
    ```
* [Explanation of the ecosystem](http://gamasutra.com/blogs/LarsDoucet/20140318/213407/Flash_is_dead_long_live_OpenFL.php)
  wonderful blog explaining the ecosystem,
  linking to relevant resources,
  suggestions for different types of use cases, etc
  definitely read this again
* REPL

  ```sh
  $ haxelib install ihx
  $ haxelib run ihx
  ```
* Graphics
  * haxeflixel
    * [examples](http://haxeflixel.com/showcase/)
    * [more examples](http://haxeflixel.com/demos/) (with source)
    * [docs](http://haxeflixel.com/documentation/)
    * [tutorial](http://haxeflixel.com/documentation/part-ii-testing/) looks good
    * [demos of FlxNape, a physics engine](http://haxeflixel.com/demos/FlxNape/)
  * [OpenFl](http://haxeui.org/install_openfl.jsp)

    ```sh
    $ haxelib install lime
    $ haxelib run lime setup
    $ lime install openfl
    ```
  * [HaxeUI](http://haxeui.org/install_haxeui.jsp)

    ```sh
    $ haxelib install haxeui
    ```
