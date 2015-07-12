"use strict";

const defineMachine = require("./machine_definitions"),
      Machine       = require("./machine")

export default function buildWorld(ast) {
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


  // nil
  const rNilClass = instantiate(rClass)
  const rNil      = instantiate(rNilClass)

  // true
  const rTrueClass = instantiate(rClass)
  const rTrue      = instantiate(rTrueClass)


  // callstack
  const main = instantiate(rObject)
  const toplevelBinding = {
    localVariables: {},
    self:           main.objectId,
    returnValue:    rNil.objectId,
  }

  // put it all together
  const world = {
    ast:            ast,
    rNil:           rNil,
    rTrue:          rTrue,
    currentBinding: toplevelBinding,
    allObjects:     allObjects
  }

  // not quite right, should be a data structure, not an object.
  world.rootMachine = new Machine(world, defineMachine())
  world.mainMachine = world.rootMachine.child("main")

  return world
}
