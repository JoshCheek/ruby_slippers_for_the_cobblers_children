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


var Tachikoma = {}

Tachikoma.wireframeMesh = function(geometry) {
  var wireframeMaterial = new THREE.MeshBasicMaterial({color: 0x000000, wireframe: true})
  var basicMaterial     = new THREE.MeshBasicMaterial({color: 0xffff00, transparent: true, opacity: 0.5})
  basicMaterial.side    = THREE.DoubleSide
  var mesh              = THREE.SceneUtils.createMultiMaterialObject(geometry, [basicMaterial, wireframeMaterial])
  return mesh
}

Tachikoma.lambertMesh = function(geometry) {
  var material = new THREE.MeshLambertMaterial({color: 0xffff00})
  var mesh     = new THREE.Mesh(geometry, material)
  return mesh
}

Josh.tachikomaMesh = function(makeMesh) {

  // -----  helper functions  -----

  var unit    = 32 // to translate everything into 'unit' sized: x, y, z all have a max of 1
  var len     = function(n)       { return n / unit }
  var vec     = function(x, y, z) { return new THREE.Vector3(len(x), len(y), len(z)) }
  var degrees = function(deg)     { return deg * Math.PI / 180 }

  function applyOffsets(offsets, object) {
    for(var axis in offsets.rotation) object.rotation[axis] = degrees(offsets.rotation[axis])
    for(var axis in offsets.position) object.position[axis] = len(offsets.position[axis])
    return object
  }


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

  var rearCabinMesh = makeMesh(rearCabinGeo)

  // -----  spinnerettes  -----

  function spinnerette(offsets) {
    var baseHeight     = len(3)
    var shooterHeight  = len(2)
    var base           = makeMesh(new THREE.CylinderGeometry(len(1),   len(1),   baseHeight,    12))
    var shooter        = makeMesh(new THREE.CylinderGeometry(len(0.15),len(0.5), shooterHeight, 12))
    shooter.position.y = baseHeight/2 + shooterHeight/2

    var spinnerette = new THREE.Object3D()
    spinnerette.add(base)
    spinnerette.add(shooter)

    applyOffsets(offsets, spinnerette)

    return spinnerette
  }


  function sideSpineretteAssembly() {
    var sphereRadius = len(3)

    // base
    var base = makeMesh(new THREE.CylinderGeometry(len(3.5),     // radius top
                                                   len(3.5),     // radius bottom
                                                   sphereRadius, // height (set to the sphere's radius to make it half as long as the sphere)
                                                   32))          // num sgements
    base.position.y = -sphereRadius/2 // lower it to the bottom half of the sphere (divide by 2, b/c it's centered on the sphere, so it's already halfway down)

    // sphere
    var sphere = makeMesh(new THREE.SphereGeometry(sphereRadius, 20, 30)) // radius, widthSegments, heightSegments

    // spinnerettes
    var backSpinnerette  = spinnerette({rotation: {x:  90}, position: {y: 2, z:  1.5}})
    var frontSpinnerette = spinnerette({rotation: {x: -90}, position: {y: 2, z: -1.5}})

    // all together now!
    return new THREE.Object3D().add(sphere).add(base).add(backSpinnerette).add(frontSpinnerette)
  }

  var leftSpineretteAssembly   = sideSpineretteAssembly().translateY(len(15)).translateX(len(-8.2)).rotateZ(degrees(90))
  var rightSpinneretteAssenbly = sideSpineretteAssembly().translateY(len(15)).translateX(len(8.2)).rotateZ(degrees(-90))
  var leftTailSpinnerette      = spinnerette({rotation: {x: 90}, position: {x:  7, y: -9, z: 10}})
  var rightTailSpinnerette     = spinnerette({rotation: {x: 90}, position: {x: -7, y: -9, z: 10}})


  // -----  neck  -----

  // cabin/neck connector
  var cabinNeckConnector        = makeMesh(new THREE.CylinderGeometry(len(5), len(5), len(12), 12))
  cabinNeckConnector.position.y = len(-6.5)
  cabinNeckConnector.position.z = len(-7)
  cabinNeckConnector.rotation.x = degrees(90);

  // joint rim
  var jointRim        = makeMesh(new THREE.CylinderGeometry(len(4), len(4), len(12), 12))
  jointRim.position.y = len(-6.5)
  jointRim.position.z = len(-8)
  jointRim.rotation.x = degrees(90)

  // ball joint
  var neckBallJoint        = makeMesh(new THREE.SphereGeometry(len(3), 20, 30))
  neckBallJoint.position.y = len(-6.5)
  neckBallJoint.position.z = len(-14)

  // main
  var neckMain         = makeMesh(new THREE.CylinderGeometry(len(4), len(3), len(12), 12))
  neckMain.position.y  = len(-6.5)
  neckMain.position.z  = len(-21)
  neckMain.rotation.x  = degrees(90)

  // -----  chin  -----

  // lower chin
  var lowerChin        = makeMesh(new THREE.CylinderGeometry(len(7), len(5), len(5), 12))
  lowerChin.position.y = len(-8)
  lowerChin.position.z = len(-25)

  // upper chin
  var upperChin        = makeMesh(new THREE.CylinderGeometry(len(13), len(7), len(5), 12))
  upperChin.position.y = len(-3)
  upperChin.position.z = len(-25)

  // -----  head  -----

  var headSphereBSP      = new ThreeBSP(new THREE.SphereGeometry(len(14), 30, 30))
  var headSubtractionBSP = new ThreeBSP(
    new THREE.ConvexGeometry([
      new THREE.Vector4(len(-14), len(-25), len(-30)), // not sure why vector4, given that we're only using 3 points
      new THREE.Vector4(len(-14), len(-25), len( 20)),
      new THREE.Vector4(len(-14), len(  5), len(-30)),
      new THREE.Vector4(len( 14), len(-25), len(-30)),
      new THREE.Vector4(len(-14), len(  5), len( 20)),
      new THREE.Vector4(len( 14), len(  5), len( 20)),
      new THREE.Vector4(len( 14), len(-25), len( 20)),
      new THREE.Vector4(len( 14), len(  5), len(-30)),
    ])
  )

  // carve cube from sphere
  var headGeo     = headSphereBSP.subtract(headSubtractionBSP).toGeometry()
  var head        = makeMesh(headGeo)
  head.position.z = len(-25)
  head.position.y = len(-5.65)

  // -----  eyes  -----

  function eye(offsets) {
    var eye = makeMesh(new THREE.SphereGeometry(len(3), 20, 30))
    applyOffsets(offsets, eye)
    return eye
  }

  // front eye
  var frontEye = eye({position: {         y:   4, z: -32}})
  var leftEye  = eye({position: {x: -6.5, y:   4, z: -25}})
  var rightEye = eye({position: {x:  6.5, y:   4, z: -25}})
  var assEye   = eye({position: {         y: -10,       }})

  // -----  chimney  -----

  // chimney base
  var chimneyBase        = makeMesh(new THREE.CylinderGeometry(len(2), len(2), len(1), 12))
  chimneyBase.position.y = len(8.5)
  chimneyBase.position.z = len(-25)

  //  chimney trunk
  var chimneyTrunk        = makeMesh(new THREE.CylinderGeometry(len(1.5), len(1.5), len(4), 12))
  chimneyTrunk.position.y = len(10)
  chimneyTrunk.position.z = len(-25)

  //  chimney tower
  var chimneyTower        = makeMesh(new THREE.CylinderGeometry(len(1), len(1), len(4), 12))
  chimneyTower.position.y = len(14)
  chimneyTower.position.z = len(-25)

  // -----  legs  -----

  // leg group!
  var rearLeftLeg = new THREE.Object3D()

  // shoulder, rear left leg
  var rearLeftLegShoulder = makeMesh(new THREE.CylinderGeometry(len(4), len(1.5), len(9), 9));
  rearLeftLegShoulder.position.x = len(-6.5)
  rearLeftLegShoulder.position.y = len(-6.5)
  rearLeftLegShoulder.position.z = len(-22)
  rearLeftLegShoulder.rotation.x = degrees(90)
  rearLeftLegShoulder.rotation.z = degrees(65)
  rearLeftLeg.add(rearLeftLegShoulder)

  // shoulder ball joint, rear left leg
  var shoulderBallJoint = makeMesh(new THREE.SphereGeometry(len(3), 20, 30))
  shoulderBallJoint.position.x = len(-11.5)
  shoulderBallJoint.position.y = len(-6.5)
  shoulderBallJoint.position.z = len(-19.5)
  rearLeftLeg.add(shoulderBallJoint)

  // "thigh", rear left leg
  var thigh = makeMesh(new THREE.CylinderGeometry(len(1.25), len(1.25), len(9), 9))
  thigh.position.x = len(-15.5)
  thigh.position.y = len(-6)
  thigh.position.z = len(-17.5)
  thigh.rotation.x = degrees(90)
  thigh.rotation.y = degrees(-25)
  thigh.rotation.z = degrees(65)
  rearLeftLeg.add(thigh)

  // knee ball joint, rear left leg
  var kneeBallJoint = makeMesh(new THREE.SphereGeometry(len(2.25), 20, 30))
  kneeBallJoint.position.x = len(-18)
  kneeBallJoint.position.y = len(-5)
  kneeBallJoint.position.z = len(-16.5)
  rearLeftLeg.add(kneeBallJoint)


  // all together for the tachikoma
  return new THREE.Object3D().add(rearCabinMesh)
                             .add(leftSpineretteAssembly)
                             .add(rightSpinneretteAssenbly)
                             .add(leftTailSpinnerette)
                             .add(rightTailSpinnerette)
                             .add(cabinNeckConnector)
                             .add(jointRim)
                             .add(neckBallJoint)
                             .add(neckMain)
                             .add(lowerChin)
                             .add(upperChin)
                             .add(head)
                             .add(frontEye)
                             .add(leftEye)
                             .add(rightEye)
                             .add(assEye)
                             .add(chimneyBase)
                             .add(chimneyTrunk)
                             .add(chimneyTower)
                             .add(rearLeftLeg)
}


Josh.renderTachikoma = function(domElement, requestAnimationFrame, frameUpdates) {
  // things in the scene
  var tachikoma = Josh.tachikomaMesh(Tachikoma.lambertMesh)
  var tachikoma = Josh.tachikomaMesh(Tachikoma.wireframeMesh)

  // scene (all the threejs objects being considered)
  var scene = new THREE.Scene()
  scene.add(Josh.ambientlight({colour: 0x222222}))
  scene.add(tachikoma)
  scene.add(Josh.spotlight({colour: 0xffffff, from: [0, 0, -10]}))  // a bit behind our camera

  // add to DOM
  var renderer = new THREE.WebGLRenderer()
  renderer.setClearColor(0xdddddd, 1.0)
  renderer.shadowMapEnabled = true // calculates shadows when true (this is apparently expensive, so turn it off if we don't wind up needing it)
  renderer.setSize(domElement.offsetWidth, domElement.offsetHeight)
  domElement.appendChild(renderer.domElement)

  // render from back a bit, looking at origin
  var camera = Josh.camera({
    from:        [0.5, 0.5, -2.5],
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

    tachikoma.rotation.y += 0.04
    frameUpdates()
    renderer.render(scene, camera)
    requestAnimationFrame(render)
  }

  render()

  return camera
}
