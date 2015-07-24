"use strict"

var Josh = {}

Josh.ambientlight = function(attrs) {
  if(attrs == undefined) attrs = {}
  var colour = attrs.colour || 0xffffff
  var light  = new THREE.AmbientLight(colour)
  return light
}

// only works on MeshLambertMaterial and MeshPhongMaterial
Josh.spotlight = function(attrs) {
  if(attrs == undefined) attrs = {}
  var colour = attrs.colour || 0xffffff
  var from   = attrs.from   || [0, 0, 0]
  // var width  = attrs.width  || 1024
  // var height = attrs.height ||
  var light  = new THREE.SpotLight(colour)
  light.position.set(from[0], from[1], from[2])

  light.castShadow       = true

  light.shadowMapWidth   = 1024
  light.shadowMapHeight  = 1024

  light.shadowCameraNear = 500
  light.shadowCameraFar  = 4000
  light.shadowCameraFov  = 30

  return light
}

// what we can see of the scene
Josh.camera = function(attrs) {
  if(attrs == undefined) attrs = {}
  var from   = attrs.from        || [0, 0, 0]
  var to     = attrs.to          || [0, 0, 0]
  var ar     = attrs.aspectRatio || 16/9
  var fov    = attrs.fieldOfView || 45
  var near   = attrs.nearPlane   || 0.1  // closest thing you can see
  var far    = attrs.farPlane    || 1000 // farthest thing you can see
  var camera = new THREE.PerspectiveCamera(fov, ar, 0.1, 100)
  camera.position.x = from[0]
  camera.position.y = from[1]
  camera.position.z = from[2]
  camera.lookAt(new THREE.Vector3(to[0], to[1], to[2]))

  return camera
}


Josh.cube = function(attrs) {
  if(attrs == undefined) attrs = {}
  var colour   = attrs.colour || 0xffffff
  var width    = attrs.width  || 1
  var height   = attrs.height || 1
  var depth    = attrs.depth  || 1
  var geometry = new THREE.BoxGeometry(width, height, depth)
  var material = new THREE.MeshLambertMaterial({color: colour})
  var cube     = new THREE.Mesh(geometry, material)
  return cube
}

Josh.sphere = function(attrs) {
  if(attrs === undefined) attrs = {}
  var colour         = attrs.colour         || 0xffffff
  var transparent    = !!attrs.transparent
  var opacity        = attrs.opacity        || 0.3
  var radius         = attrs.radius         || 1
  var widthSegments  = attrs.widthSegments  || 32
  var heightSegments = attrs.heightSegments || 32
  var geometry       = new THREE.SphereGeometry(radius, widthSegments, heightSegments)
  var material       = new THREE.MeshLambertMaterial({color: colour, transparent: transparent, opacity: opacity})
  var sphere         = new THREE.Mesh(geometry, material)
  return sphere
}

Josh.statistics = function() {
  var stats = new Stats()
  stats.setMode(0) // count the frames per second
  return stats
}

Josh.renderExample = function(domElement, requestAnimationFrame, frameUpdates) {
  // things in the scene
  var cube1       = Josh.cube({colour: 0x008822})
  var cube2       = Josh.cube({colour: 0x888800})
  var leftSphere  = Josh.sphere({transparent: true})
  var rightSphere = Josh.sphere({transparent: true})

  // scene (all the threejs objects being considered)
  var scene = new THREE.Scene()
  scene.add(Josh.ambientlight({colour: 0x000033}))                  // blue ambient light
  scene.add(Josh.spotlight({colour: 0xffffff, from: [0, 0, -10]}))  // a bit behind our camera
  scene.add(cube1);
  scene.add(cube2);
  scene.add(leftSphere)
  scene.add(rightSphere)

  // add to DOM
  var renderer = new THREE.WebGLRenderer()
  renderer.setClearColor(0x222222, 1.0)
  renderer.shadowMapEnabled = false // calculates shadows when true (this is apparently expensive, so turn it off if we don't wind up needing it)
  renderer.setSize(domElement.offsetWidth, domElement.offsetHeight)
  domElement.appendChild(renderer.domElement)

  // render from back a bit, looking at origin
  var camera = Josh.camera({
    from:        [0, 0, -5],
    aspectRatio: domElement.offsetWidth / domElement.offsetHeight,
  })

  // render this shit
  var framecount = 0

  var render = function() {
    framecount++ // render half as frequently since 60fps seems to be a lot

    if((framecount%2) == 0) {
      requestAnimationFrame(render)
      return
    }

    // examples of things we can change in here
    cube1.rotation.x       = framecount * 0.03
    cube2.rotation.y       = framecount * 0.01
    leftSphere.position.x  = framecount * 0.01
    rightSphere.position.z = framecount * -0.01

    frameUpdates()
    renderer.render(scene, camera)
    requestAnimationFrame(render)
  }

  render()
}

Josh.wireframe = function(geometry) {
  var wireframeMaterial = new THREE.MeshBasicMaterial({color: 0x000000, wireframe: true})
  var basicMaterial     = new THREE.MeshBasicMaterial({color: 0xffff00, transparent: true, opacity: 0.5})
  basicMaterial.side    = THREE.DoubleSide
  var mesh              = THREE.SceneUtils.createMultiMaterialObject(geometry, [basicMaterial, wireframeMaterial])
  return mesh
}


Josh.tachikomaMesh = function() {
  // -----  helper functions  -----
  var unit    = 32 // to translate everything into 'unit' sized: x, y, z all have a max of 1
  var len     = function(n)       { return n / unit }
  var vec     = function(x, y, z) { return new THREE.Vector3(len(x), len(y), len(z)) }
  var degrees = function(deg)     { return deg * Math.PI / 180 }


  // -----  rear cabin  -----
  var rearCabinGeo = new THREE.ConvexGeometry([
    // top tapering
    vec(-4, 24, -6),
    vec(4,  24, -6),
    vec(-4, 24,  4),
    vec(4,  24,  4),

    // top
    vec(-7, 23, -9),
    vec( 7, 23, -9),
    vec(-7, 23,  7),
    vec( 7, 23,  7),

    // bottom
    vec(-10, -10, -10),
    vec( 10, -10, -10),
    vec(-10, -10,  10),
    vec( 10, -10,  10),

    // bottom tapering
    vec(-8, -12, -8),
    vec( 8, -12, -8),
    vec(-8, -12,  8),
    vec( 8, -12,  8),
  ])

  var rearCabinMesh = Josh.wireframe(rearCabinGeo)


  // -----  spinnerets  -----
  function spinnerette() {
    var sphereRadius = len(3)

    // reservoir
    var reservoir = Josh.wireframe(new THREE.CylinderGeometry(len(3.5),     // radius top
                                                              len(3.5),     // radius bottom
                                                              sphereRadius, // height (set to the sphere's radius to make it half as long as the sphere)
                                                              32))          // num sgements
    reservoir.position.y = -sphereRadius/2 // divide by 2, b/c it's centered on the sphere, so it's already halfway down

    // sphere
    var sphere = Josh.wireframe(new THREE.SphereGeometry(sphereRadius, 20, 30)) // radius, widthSegments, heightSegments

    // base
    var base        = Josh.wireframe(new THREE.CylinderGeometry(len(1), len(1), sphereRadius*2, 12))
    base.position.y = len(2)
    base.rotation.x = degrees(90)

    // base fore
    var baseFore        = Josh.wireframe(new THREE.CylinderGeometry(len(0.5), len(0.15), len(2), 12))
    baseFore.position.y = len(2)
    baseFore.position.z = len(-4)
    baseFore.rotation.x = degrees(90)

    // base aft
    var baseAft        = Josh.wireframe(new THREE.CylinderGeometry(len(0.5), len(0.15), len(2), 12))
    baseAft.position.y = len(2)
    baseAft.position.z = len(4)
    baseAft.rotation.x = degrees(-90)

    // spinnerette
    var spinnerette = new THREE.Object3D()
    spinnerette.add(reservoir)
    spinnerette.add(sphere)
    spinnerette.add(base)
    spinnerette.add(baseFore)
    spinnerette.add(baseAft)

    return spinnerette
  }

  // all together for the tachikoma
  var tachikoma = new THREE.Object3D()
  tachikoma.add(rearCabinMesh)

  var leftSpinnerette  = spinnerette().translateY(len(15)).translateX(len(-8)).rotateZ(degrees(90))
  var rightSpinnerette = spinnerette().translateY(len(15)).translateX(len(8)).rotateZ(degrees(-90))
  tachikoma.add(leftSpinnerette)
  tachikoma.add(rightSpinnerette)

  return tachikoma
}


Josh.renderTachikoma = function(domElement, requestAnimationFrame, frameUpdates) {
  // things in the scene
  var tachikoma = Josh.tachikomaMesh()

  // scene (all the threejs objects being considered)
  var scene = new THREE.Scene()
  scene.add(Josh.ambientlight({colour: 0xffffff}))
  scene.add(tachikoma)

  // add to DOM
  var renderer = new THREE.WebGLRenderer()
  renderer.setClearColor(0xdddddd, 1.0)
  renderer.shadowMapEnabled = true // calculates shadows when true (this is apparently expensive, so turn it off if we don't wind up needing it)
  renderer.setSize(domElement.offsetWidth, domElement.offsetHeight)
  domElement.appendChild(renderer.domElement)

  // render from back a bit, looking at origin
  var camera = Josh.camera({
    from:        [0.5, 0.5, -2],
    to:          [0.0, 0.2,  0],
    aspectRatio: domElement.offsetWidth / domElement.offsetHeight,
  })

  // render this shit
  var framecount = 0

  var render = function() {
    framecount++ // render half as frequently since 60fps seems to be a lot

    if((framecount%2) == 0) {
      requestAnimationFrame(render)
      return
    }

    tachikoma.rotation.y += 0.02
    frameUpdates()
    renderer.render(scene, camera)
    requestAnimationFrame(render)
  }

  render()

  return camera
}
