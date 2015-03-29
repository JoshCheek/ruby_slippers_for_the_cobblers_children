Environment
-----------

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

Plan
----

* Pick a transpiler
  * esprima
    * parses js
    * https://www.npmjs.com/package/esprima
  * acorn
    * "supports the entirety of the ES6 spec and is 2x faster than esprima" (https://github.com/babel/babel/issues/581#issuecomment-72745404)
    * https://www.npmjs.com/package/acorn
  * recast
    * Lib for rewriting JavaScript code
    * https://github.com/benjamn/recast
  * traceur
    * transpiler
    * http://google.github.io/traceur-compiler/demo/repl.html#%2F%2F%20Options%3A%20--async-functions%0A%0Afunction%20timeout(ms)%20%7B%0A%20%20return%20new%20Promise((res)%20%3D%3E%20setTimeout(res%2C%20ms))%3B%0A%7D%0A%0Aasync%20function%20f()%20%7B%0A%20%20console.log(1)%3B%0A%20%20await%20timeout(1000)%3B%0A%20%20console.log(2)%3B%0A%20%20await%20timeout(1000)%3B%0A%20%20console.log(3)%3B%0A%7D%0A%0Af()%0A%0A
  * babel (6to5)
    * https://babeljs.io
  * sweet.js
    * macros
    * http://sweetjs.org/
* Get the tools installed
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
