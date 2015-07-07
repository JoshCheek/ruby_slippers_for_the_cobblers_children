module.exports = buildWorld

function buildWorld(ast) {
  // All Objects
  let nextObjectId = 1
  let allObjects = {
    track: function(toTrack) {
      allObjects[nextObjectId] = toTrack
      toTrack.objectId = nextObjectId
      ++nextObjectId
      return toTrack
    }
  }


  // helpers
  let instantiate = function(klass) {
    let instance = { class: klass.objectId, instanceVariables: {} }
    allObjects.track(instance)
    if(klass.internalInit)
      klass.internalInit(instance)
    return instance
  }

  // BasicObject, Object, Class
  let rClass  = allObjects.track({instanceVariables: {}})
  rClass.class = rClass.objectId

  let rBasicObject = allObjects.track({
    class:             rClass.objectId,
    instanceVariables: {},
  })

  let rObject = allObjects.track({
    class:             rClass.objectId,
    instanceVariables: {},
  })

  rClass.internalInit = function(newClass) {
    newClass.constants       = {}
    newClass.instanceMethods = {}
    newClass.superclass      = rObject.objectId
  }

  rClass.internalInit(rBasicObject)
  rClass.internalInit(rObject)
  rClass.internalInit(rClass)

  rObject.constants["BasicObject"] = rBasicObject.objectId
  rObject.constants["Object"]      = rObject.objectId
  rObject.constants["Class"]       = rClass.objectId


  // true
  let rTrueClass = instantiate(rClass)
  let rTrue      = instantiate(rTrueClass)

  // nil
  let rNilClass = instantiate(rClass)
  let rNil      = instantiate(rNilClass)


  // callstack
  let main = instantiate(rObject)
  let toplevelBinding = {
    localVariables: {},
    self:           main.objectId,
    returnValue:    rNil.objectId,
  }
  let callstack = [toplevelBinding]

  // put it all together
  let world = {
    ast:        ast,
    statestack: [{name: "start", registers: {}}],
    rNil:       rNil,
    rTrue:      rTrue,
    callstack:  callstack,
    allObjects: allObjects
  }

  return world
}
