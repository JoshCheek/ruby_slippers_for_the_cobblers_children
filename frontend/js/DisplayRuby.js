var DisplayRuby = function(attributes) {
  // -----  lights  ------
  var ambientLight = new THREE.AmbientLight(0x0c0c0c)
  var spotLight    = new THREE.SpotLight(0xF5AA7730)
  spotLight.position.set(0, 5, -10)
  spotLight.intensity = 0.9

  // -----  scene  -----
  this.scene = new THREE.Scene()
  this.scene.add(ambientLight)
  this.scene.add(spotLight)

  // -----  ruby  ------
  // THOUGHT: It should create the initial world, and then hook into each machine's changes
  // updates to the view are based on receiving a callback with the given machine and its bytecode
  // this should happen in the step() method on the vm.
  //
  // This might require the .definitions file to be split up, such that instructions can be defined independently of machines,
  // b/c this would imply that there are multiple sets of instructions for each bytecode
  var world = attributes.world
  this.bindingStack = this.makeBindingStack(world, this.scene)

  // -----  renderer  -----
  this.renderer = new THREE.WebGLRenderer()
  this.renderer.setClearColor(0x2A211C, 1.0)
  this.renderer.shadowMapEnabled = false

  // -----  camera  -----
  this.camera = new THREE.PerspectiveCamera(45, 16/9, 0.1, 100)
  this.camera.position.x = 0
  this.camera.position.y = 0
  this.camera.position.z = -10
  this.camera.lookAt(new THREE.Vector3(0, 0, 0)) // origin

  // -----  set width and height  -----
  this.updateSize(attributes.width, attributes.height)

  // -----  iteration  -----
  this.iteration = 0
}

DisplayRuby.prototype.domElement = function() {
  return this.renderer.domElement
}

DisplayRuby.prototype.updateWidth  = function(width)  { this.updateSize(width, this.height) }
DisplayRuby.prototype.updateHeight = function(height) { this.updateSize(this.width, height) }
DisplayRuby.prototype.updateSize   = function(width, height) {
  this.width       = width
  this.height      = height
  this.aspectRatio = width / height
  this.renderer.setSize(width, height)
  this.camera.aspect = this.aspectRatio
  this.camera.updateProjectionMatrix()
  return this
}


DisplayRuby.prototype.update = function(width, height, world) {
  var that = this

  this.iteration++

  var numBindings = 0

  var binding = world.$bindingStack
  while(binding !== null) {
    console.log("BINDING: " + binding)
    var bindingView = that.bindingStack[numBindings]
    if(bindingView === undefined) {
      bindingView = this.makeBinding(world, binding)
      this.bindingStack.push(bindingView)
      this.scene.add(bindingView.image)
    }
    bindingView.update(binding)
    binding = binding.caller
    numBindings++
  }

  while(numBindings < this.bindingStack.length)
    this.bindingStack.pop()

  // make any relevant updates to the internal representation of the world, here
  this.renderer.render(this.scene, this.camera)
}


DisplayRuby.prototype.makeBindingStack = function(world, scene) {
  var bindingStack   = []
  var currentBinding = world.$bindingStack

  while(currentBinding !== null) {
    var bindingView = this.makeBinding(world, currentBinding)
    bindingStack.push(bindingView)
    scene.add(bindingView.image)
    currentBinding = currentBinding.caller
  }

  return bindingStack
}


DisplayRuby.prototype.makeBinding = function(world, currentBinding) {
  var bindingView = {
    image:          new THREE.Object3D(),
    binding:        currentBinding,
    localVariables: {},
    update:         function(binding) { },
    // self:           main,
    // returnValue:    rNil,
    // caller:         null,
  }

  bindingView.image.add(
    new THREE.Mesh(
      new THREE.SphereGeometry(1, 30, 30),
      new THREE.MeshLambertMaterial({color: 0xffffff})
    )
  )

  return bindingView
}


// --------------------------
// DisplayRuby.BindingStack = function(attributes) {
//   this.scene = attributes.scene
//   this.stack = []
//   var world = attributes.world
//   world.$bindingStack.forEach(function(rubyBinding) {
//     this.stack.push(new DisplayRuby.Binding(
//   })
// }

// this.cube = new THREE.Mesh(new THREE.BoxGeometry(1, 1, 1),
//                            new THREE.MeshLambertMaterial({color: 0xffff00}))
// this.scene.add(this.cube)

// QUESTION: is the most interesting thing the current machine? Maybe we should just follow that machine around, and let all this shit sit out here in the world?
//
// draw the relevant objects, given the current focus
// objects: show the class pointer, show the ivars floating inside of it
// classes: when used like an object, display like an object.
//          when used like a class, display like a class
// stack:

// REFERENCE:
//   $allObjects (hash, keys are object ids, values are the objects they point at)
//     object
//       { class: klass, instanceVariables: {}, inspect: customInspect }
//     classes
//       newClass.constants       = {}
//       newClass.instanceMethods = {}
//       newClass.superclass      = rObject
//   $bindingStack
//     localVariables: {},
//     self:           main,
//     returnValue:    rNil,
//     caller:         null,
//   $machineStack
//       $machineStack:      {
//         definition         : machineDefinitions.children["main"],
//         parent             : null,
//         registers          : {},
//         instructionPointer : 0,
//       },
//   $rootMachine:
//     { "name": "main",
//       "description": "The main machine, kicks everything else off",
//       "namespace": [],
//       "arg_names": [],
//       "labels": {},
//       "instructions": [
//         ["globalToRegister", "$rTOPLEVEL_BINDING", "@_1"],
//         // ...
//       ],
//       "children": {},
//     },
