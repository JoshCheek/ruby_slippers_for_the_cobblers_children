"use strict";

const machineDefinitions = require("./machine_definitions")()

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
    const instance = { class: klass, instanceVariables: {}, inspect: customInspect }
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

  // nil
  const rNilClass = instantiate(rClass,    () => "rNilClass")
  const rNil      = instantiate(rNilClass, () => "rNil")

  // true
  const rTrueClass = instantiate(rClass,     () => "rTrueClass")
  const rTrue      = instantiate(rTrueClass, () => "rTrue")

  // false
  const rFalseClass = instantiate(rClass,      () => "rFalseClass")
  const rFalse      = instantiate(rFalseClass, () => "rFalse")

  // String
  const rString     = instantiate(rClass,      () => "rString")

  // callstack
  const main = instantiate(rObject, () => "rMain")
  const toplevelBinding = {
    localVariables: {},
    self:           main,
    returnValue:    rNil,
    caller:         null,
  }

  // constants
  const toplevelNamespace = rObject
  toplevelNamespace.constants["TOPLEVEL_BINDING"] = toplevelBinding
  toplevelNamespace.constants["BasicObject"]      = rBasicObject
  toplevelNamespace.constants["Object"]           = rObject
  toplevelNamespace.constants["Class"]            = rClass
  toplevelNamespace.constants["String"]           = rString
  toplevelNamespace.constants["NilClass"]         = rNilClass
  toplevelNamespace.constants["TrueClass"]        = rTrueClass
  toplevelNamespace.constants["FalseClass"]       = rFalseClass

  // put it all together
  return {
    // important starting places
    $toplevelNamespace: toplevelNamespace,
    $rMain:             main,
    $rTOPLEVEL_BINDING: toplevelBinding,
    $bindingStack:      null,              // callstack
    $deftargetStack:    null,              // which class/method `def` will add the method to

    // garbage collection or something
    $allObjects:        allObjects,

    // code evaluation
    $foundExpression:   false,
    $ast:               ast,                // the code to execute
    $rootMachine:       machineDefinitions, // the instructions for manipulating the world
    $machineStack:      {
      definition         : machineDefinitions.children["main"],
      parent             : null,
      registers          : {},
      instructionPointer : 0,
    },

    // convenience objects
    $rNil:              rNil,
    $rTrue:             rTrue,
    $rFalse:            rFalse,
    $rString:           rString,
    $rObject:           rObject,
  }
}
