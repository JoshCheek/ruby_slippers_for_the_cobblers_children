var DisplayRuby = function(attributes) {
  // ambient light
  var ambientLight = new THREE.AmbientLight(0x0c0c0c)

  // spotlight (only works on MeshLambertMaterial and MeshPhongMaterial)
  var spotLight  = new THREE.SpotLight(0xffffff)
  spotLight.position.set(0, 5, -10)
  spotLight.castShadow       = true

  spotLight.shadowMapWidth   = 1024
  spotLight.shadowMapHeight  = 1024

  spotLight.shadowCameraNear = 500
  spotLight.shadowCameraFar  = 4000
  spotLight.shadowCameraFov  = 30

  spotLight.intensity        = 0.9

  // temporary cube to prove this setup works
  var geometry = new THREE.BoxGeometry(1, 1, 1)
  var material = new THREE.MeshLambertMaterial({color: 0xffff00})
  this.cube    = new THREE.Mesh(geometry, material)

  // scene
  this.scene = new THREE.Scene()
  this.scene.add(ambientLight)
  this.scene.add(spotLight)
  this.scene.add(this.cube)

  // renderer
  this.renderer = new THREE.WebGLRenderer()
  this.renderer.setClearColor(0x222222, 1.0)
  this.renderer.shadowMapEnabled = false // calculates shadows when true (this is apparently expensive, so turn it off if we don't wind up needing it)

  // camera
  this.camera = new THREE.PerspectiveCamera(45,   // field of view
                                            16/9, // aspect ratio (will be updated when we set the size)
                                            0.1,  // near plane (closest thing you can see)
                                            100)  // far plane (farthest thing you can see)
  this.camera.position.x = 0
  this.camera.position.y = 0
  this.camera.position.z = -10
  this.camera.lookAt(new THREE.Vector3(0, 0, 0)) // origin

  this.updateSize(attributes.width, attributes.height)

  // iteration
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
  // this.camera.aspect(this.aspectRatio)
  return this
}


DisplayRuby.prototype.update = function(width, height) {
  this.iteration++
  this.cube.rotation.x = this.iteration * 0.01
  this.cube.rotation.y = this.iteration * 0.02
  this.renderer.render(this.scene, this.camera)
}
