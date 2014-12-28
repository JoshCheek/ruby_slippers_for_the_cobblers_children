(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function () { "use strict";
var HxHw = function() { };
HxHw.helloWorld = function() {
	return "HAXE greets the world!";
};
HxHw.main = function() {
	module.exports = HxHw;
};
HxHw.main();
})();

},{}],2:[function(require,module,exports){
"use strict";

var JsHw = function() { };

JsHw.helloWorld = function() {
  return "JAVASCRIPT greets the world!";
};

module.exports = JsHw;

},{}],3:[function(require,module,exports){
var js_hw = require('js_hw');
console.log(js_hw.helloWorld());

var hx_hw = require('hx_hw');
console.log(hx_hw.helloWorld());

},{"hx_hw":1,"js_hw":2}]},{},[3])