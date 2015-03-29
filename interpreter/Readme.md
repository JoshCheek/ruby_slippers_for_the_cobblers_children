Tooling
-------

* Interpreter (like MRI) [Nodejs](https://nodejs.org/) or [Iojs](https://iojs.org/en/index.html)
* Package manager (like Rubygems) [Npm](https://www.npmjs.com)
* Build tool (like Rake or Make)
  * [Gulp](https://www.npmjs.com/package/gulp) here is a
    [sample gulpfile.js](https://github.com/megawac/generator-babel-node/blob/5ed278c9f9e18e1f9ffbab60a9f87fd958da0f5d/app/templates/gulpfile.js)
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

Plan
----

* Get the tools installed
* Get a simple test in place that uses these tools, to see how they fit together
* Get it parsing

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
