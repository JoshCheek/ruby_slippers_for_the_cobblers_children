module.exports = buildWorld
const Machines = require("./load_machines")({})

function buildWorld(ast) {
  // All Objects
  let nextObjectId = 1
  const allObjects = {
    track: function(toTrack) {
      allObjects[nextObjectId] = toTrack
      toTrack.objectId = nextObjectId
      ++nextObjectId
      return toTrack
    }
  }


  // helpers
  const instantiate = function(klass) {
    const instance = { class: klass.objectId, instanceVariables: {} }
    allObjects.track(instance)
    if(klass.internalInit)
      klass.internalInit(instance)
    return instance
  }

  // BasicObject, Object, Class
  const rClass  = allObjects.track({instanceVariables: {}})
  rClass.class = rClass.objectId

  const rBasicObject = allObjects.track({
    class:             rClass.objectId,
    instanceVariables: {},
  })

  const rObject = allObjects.track({
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
  const rTrueClass = instantiate(rClass)
  const rTrue      = instantiate(rTrueClass)

  // nil
  const rNilClass = instantiate(rClass)
  const rNil      = instantiate(rNilClass)


  // callstack
  const main = instantiate(rObject)
  const toplevelBinding = {
    localVariables: {},
    self:           main.objectId,
    returnValue:    rNil.objectId,
  }
  const callstack = [toplevelBinding]

  // put it all together
  const world = {
    ast:         ast,
    rNil:        rNil,
    rTrue:       rTrue,
    callstack:   callstack,
    allObjects:  allObjects
  }
  world.mainMachine = Machines.main(world)

  return world
}
