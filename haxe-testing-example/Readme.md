Example of a simple test to keep around for reference until I actually learn this stuff.

* This example uses the built-in haxe.unit
* Run tests with `rake`, or `haxe compile.hxml && neko mytest.n`
* Based on [this tutorial](http://old.haxe.org/doc/cross/unit).
* [haxe.unit docs](docs: http://api.haxe.org/haxe/unit/index.html)
* Test method names start with `test`, I assume this is due to reflection in the runner
* There is an alternative, [munit](https://github.com/massiveinteractive/MassiveUnit), if this suite gets annoying.
  * It requires you to suffix all test classes with `Test`, which is less annoying than prefixing all methods with `test`
  * It is metadata based (you tag methods with things like @Test), which seems nicer than the method-name beginning with `test` that haxe.unit requires
  * Looks like I could make my own formatter if its output gets annoying
  * Supports Asynch tests (which I assume means it will run multiple tests simultaneously)
  * Still file-based, which is annoying
