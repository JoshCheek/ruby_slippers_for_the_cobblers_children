Frontend
========

Trying to draw the interpreter

Compiling the interpreter
-------------------------

```fish
$ cd ../interpreter
$ babel src -d compiled
$ browserify -o ruby.js (find compiled -type f) -r ./compiled/ruby.js:ruby
$ mv ruby.js ../frontend/js/ruby.js
```

Todo
----

* integrate w/ interpreter
  * set it up to not run until you click a form button
  * render the world
  * have it kick off the interpreter, slowly iterating through it and drawing the world as it does so


Notes
-----

```
Reacting to changes in the world (so we can draw them)
  react.js
    https://facebook.github.io/react/
  diffDOM
    does what Elm does with the DOM (only update changes), but is a pure js lib
    https://github.com/fiduswriter/diffDOM/issues
  keyboard events
    https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent
  binding callback to event
    https://developer.mozilla.org/en-US/docs/Web/API/EventTarget.addEventListener
Game Engines
  https://github.com/showcases/javascript-game-engines
Darwing
  2D
    paper.js
      /Users/josh/deleteme/paperjs_workshop
    Canvas
      tutorial
        https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial
      basic usage
        https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Basic_usage
  3D
    csg.js
      http://evanw.github.io/csg.js/docs/
      Don't exactly know what it is, but looks like a relatively easy lib
      to allow you to do JS graphics
      could be fun, might learn some math and some JS
    three.js
      http://threejs.org/examples/#raytracing_sandbox
      examples
        https://www.leiainc.com/
        http://www.sitepoint.com/building-earth-with-webgl-javascript/?utm_source=javascriptweekly&utm_medium=email
      tutorial
        http://code.tutsplus.com/tutorials/webgl-with-threejs-models-and-animation--net-35993
      using with Blender
        https://www.blend4web.com/en/article/36
      examples
        https://stemkoski.github.io/Three.js/
      Particle Engine (smoke, fire, clouds, starts, rain, etc)
        https://stemkoski.github.io/Three.js/Particle-Engine.html
      MSDN article on physics engines, I think :P
        https://msdn.microsoft.com/en-us/library/dn528557(v=vs.85).aspx
Atom Shell
  For making native GUI apps by treating them like the browser (builds on Chromium)
  forum
    https://discuss.atom.io/c/atom-shell
  repo
    https://github.com/atom/atom-shell
  example app
    https://github.com/dougnukem/hello-atom
    https://github.com/atom/atom-shell/blob/master/docs/tutorial/quick-start.md
```

Three.js notes from Giles lesson
--------------------------------

```
extrusion
  gives a 2d object 3d-ness

parametric primitives (aka platonics)
  sounds like vectorness

use bool operations
  differences of shapes and such

cartesian plane
  2 dimensions (x, y)

three.js / webgl
  fragments are "faces" (I think 2d)
  learningwebgl.com

  geometry
    the shape
    they have their own set of axes
    ie their x, y, z don't necessarily map to those in the world,
    so you can put them into containers with expected axes
    therefore, it also has its own origin

  mesh
    geometry + material

  scene
    mesh, light, camera

CODE!
  webGLRenderer.shadowMapEnabled = true;
    Turn on shadow calculations
    (off by default, b/c it's expensive)

  var camera = new THREE.PerspectiveCamera(45,
    window.innerWidth / window.innerHeight, 0.1, 1000);
    # 45 = field of view (how far it can see?)
    # aspect ratio (16x9 typically)
    # nearest plane  (closest thing you can see)
    # farthest plane (farthest thing you can see)

  stats
    setMode(0) // count the frames per second
```
