The Interpreter
===============

Written in [Haxe](http://haxe.org/),
this will render into JavaScript or Flash
and be executed in the browser,
so it can interpret a user's code.

* To run tests `rake interpreter:test`

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
