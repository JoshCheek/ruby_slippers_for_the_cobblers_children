Plan
----

* Get the tools installed
* Get a simple test in place that uses these tools, to see how they fit together
* Get it parsing

Tooling
-------

* Interpreter (like MRI) [Nodejs](https://nodejs.org/) or [Iojs](https://iojs.org/en/index.html)
* Package manager (like Rubygems) [Npm](https://www.npmjs.com)
* Build tool (like Rake or Make)

  Okay, apparently [Gulp](https://www.npmjs.com/package/gulp)
  is supposed to be better than
  [Grunt](https://www.npmjs.com/package/grunt),
  according to the like 5 blogs / articles that I read.
  But after about 4 hours, I couldn't get it to fucking generate a JSON file from a JavaScript object,
  and I found the process of trying to figure out how to do so to be incredibly frustrating and opque.

  I also looked at [Broccoli](https://www.npmjs.com/package/broccoli),
  but it says its a "client-side asset builder", which, really,
  is about what Gulp was ("asset builder", not "build system", like it bills itself).
  Further, I'm not dealing with client-side stuff at this point, so ignoring that one.

  Would have tried [Cake](https://www.npmjs.com/package/cake), too,
  but it says its for "A fork of CoffeeScript's cake utility so that it might be used with e.g. coffee-script-redux"
  And it became rather unclear to me what the relationship was between Coffeescript and Coffeescript Redux.
  The main Coffeescript page says nothing about it, and when I went to install Coffeescript,
  it issued me six warnings that made it unclear if it would work correctly,
  and its main page hadn't been worked on in close to a month.
  Probably best to avoid depending on that one.

  So... fuck all that shit, I'll stick with tools I know: Ruby and maybe Rake at some point, we'll see.
  Side note: literally wrote the code in under 2 min and it did the right thing the first time.
* Testing
  * Test framework: [Mocha](http://mochajs.org)
  * Assertion Library: [Chai](http://chaijs.com)
  * Someone's "getting started" walkthrough http://brianstoner.com/blog/testing-in-nodejs-with-mocha/
  * Another "getting started" walkthrough http://robdodson.me/blog/2012/05/27/testing-backbone-boilerplate-with-mocha-and-chai/
  * Fake server with [sinon](http://thejsguy.com/2015/01/12/jasmine-vs-mocha-chai-and-sinon.html)
  * Possibly [Karma](https://www.npmjs.com/package/karma), a test runner, but I can't tell if it can run tests in the shell,
    or if its just for the browser (and one of these things I read said that mocha had its own runner, anyway)
  * Code coverage (like simplecov) [istanbul](https://github.com/gotwarlost/istanbul) though, tbh,
    I've never been super impressed by these, and I've never been concerned that I was lacking coverage.
* Better JavaScript
  * Macros [sweet.js](http://sweetjs.org/) oh god this is going to cost me a log of time and make my code incomprehensible O.o
  * [babel](https://babeljs.io) transpiles javascript
  * [Coffeescript ](http://coffeescript.org/) Going to hold off on this for a bit,
    b/c babel and sweet.js seem too wonderful, but I really love the overall lack of syntax.

Installation
------------

```
# https://github.com/gulpjs/gulp/blob/3457d0ffc95f6fd971f513a8cec4ee9e0bcc0c28/docs/getting-started.md
$ npm install --global   gulp
$ npm install --save-dev gulp
$ npm install --save-dev gulp-babel
$ npm install --save-dev gulp-mocha
```

Building
--------

```
$ gulp       # generates output files via babel
$ gulp mocha # run tests
```


Javascript Resources
--------------------

* language overview
  * http://ecma262-5.com/ELS5_Section_4.htm#Section_4.3.19
* Array reference
  * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array
* List of all methods
  * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Methods_Index
* Create asynchronous functions with setTimeout
  * http://blog.scottmessinger.com/post/10368818426/creating-asynchronous-functions-in-javascript
* XMLHttpRequest can do synchronous and asynchronous requests
  * https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Synchronous_and_Asynchronous_Requests
* Write JS modules that work both in nodejs and the browser using requirejs
  * https://alicoding.com/write-javascript-modules-that-works-both-in-nodejs-and-browser-with-requirejs/
* async
  * http://jakearchibald.com/2014/es7-async-functions/
  * http://calculist.org/blog/2011/12/14/why-coroutines-wont-work-on-the-web/
  * https://github.com/lukehoban/ecmascript-asyncawait/issues/7
