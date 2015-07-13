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
  const instantiate = function(klass, customInspect) {
    if(!customInspect) customInspect = function() { return `#<${klass.inspect()}:${this.objectId}>` }
    const instance = { class: klass.objectId, instanceVariables: {}, inspect: customInspect }
    allObjects.track(instance)
    if(klass.internalInit)
      klass.internalInit(instance)
    return instance
  }

  // BasicObject, Object, Class
  const rClass  = allObjects.track({
    instanceVariables: {},
    inspect: () => "rClass"
  })
  rClass.class = rClass

  const rBasicObject = allObjects.track({
    class:             rClass,
    instanceVariables: {},
    inspect:           () => "rBasicObject",
  })

  const rObject = allObjects.track({
    class:             rClass,
    instanceVariables: {},
    inspect:           () => "rObject",
  })

  rClass.internalInit = function(newClass) {
    newClass.constants       = {}
    newClass.instanceMethods = {}
    newClass.superclass      = rObject
  }

  rClass.internalInit(rBasicObject)
  rClass.internalInit(rObject)
  rClass.internalInit(rClass)

  rObject.constants["BasicObject"] = rBasicObject
  rObject.constants["Object"]      = rObject
  rObject.constants["Class"]       = rClass


  // nil
  const rNilClass = instantiate(rClass,    () => "rNilClass")
  const rNil      = instantiate(rNilClass, () => "rNil")

  // true
  const rTrueClass = instantiate(rClass,     () => "rTrueClass")
  const rTrue      = instantiate(rTrueClass, () => "rTrue")


  // callstack
  const main = instantiate(rObject, () => "rMain")
  const toplevelBinding = {
    localVariables: {},
    self:           main,
    returnValue:    rNil,
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
  world.rootMachine  = new Machine(world, defineMachine(), null)
  world.machineStack = world.rootMachine.child("main", null)

  return world
}
