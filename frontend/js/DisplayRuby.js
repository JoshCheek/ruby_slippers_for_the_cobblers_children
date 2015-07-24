var DisplayRuby = function(attributes) {
  // lights
  var ambientLight = new THREE.AmbientLight(0x0c0c0c)
  var spotLight    = new THREE.SpotLight(0xffffff)
  spotLight.position.set(0, 5, -10)
  spotLight.intensity = 0.9

  // temporary cube to prove this setup works
  this.cube = new THREE.Mesh(new THREE.BoxGeometry(1, 1, 1),
                             new THREE.MeshLambertMaterial({color: 0xffff00}))

  // scene
  this.scene = new THREE.Scene()
  this.scene.add(ambientLight)
  this.scene.add(spotLight)
  this.scene.add(this.cube)

  // renderer
  this.renderer = new THREE.WebGLRenderer()
  this.renderer.setClearColor(0x222222, 1.0)
  this.renderer.shadowMapEnabled = false

  // camera
  this.camera = new THREE.PerspectiveCamera(45, 16/9, 0.1, 100)
  this.camera.position.x = 0
  this.camera.position.y = 0
  this.camera.position.z = -10
  this.camera.lookAt(new THREE.Vector3(0, 0, 0)) // origin

  // set width and height
  this.updateSize(attributes.width, attributes.height)

  // iteration
  this.iteration = 0
}

DisplayRuby.prototype.domElement = function() {
  return this.renderer.domElement
}

DisplayRuby.prototype.updateWidth  = function(width)  { this.updateSize(width, this.height) }
DisplayRuby.prototype.updateHeight = function(height) { this.updateSize(this.width, height) }
DisplayRuby.prototype.updateSize   = function(width, height, world) {
  this.width       = width
  this.height      = height
  this.aspectRatio = width / height
  this.renderer.setSize(width, height)
  this.camera.aspect = this.aspectRatio
  this.camera.updateProjectionMatrix()
  return this
}


DisplayRuby.prototype.update = function(width, height) {
  this.iteration++
  this.cube.rotation.x = this.iteration * 0.01
  this.cube.rotation.y = this.iteration * 0.02
  this.renderer.render(this.scene, this.camera)
}
