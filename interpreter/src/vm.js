var VM = function(world) {
  this.world = world
}

VM.prototype.currentBinding = function() {
  return this.world.callstack[this.world.callstack.length-1]
}

VM.prototype.currentExpression = function() {
  const id = this.currentBinding().returnValue
  return this.lookup(id)
}

VM.prototype.lookup = function(id) {
  return this.world.allObjects[id]
}


VM.prototype.advanceState = function() {
  let rTrue = this.world.rTrue

  let tmpBullshit = function(ast) {
    switch(ast.type) {
      case "true":
        this.currentBinding().returnValue = rTrue.objectId
        return rTrue
      default: throw(`Unexpected ast: ${ast}`)
    }
  }

  const state = this.world.state
  switch(state.name) {
    case "start":
      this.world.state = {name: "finished"}
      return tmpBullshit.call(this, this.world.ast)
    case "finished":
      return this.world.rNil
    default: throw(`Unexpected state: ${this.world.state}`)
  }
}

VM.prototype.nextExpression = function() {
  return this.advanceState()
}


VM.bootstrap = function(ast) {
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
    state:      {name: "start"},
    rNil:       rNil,
    rTrue:      rTrue,
    callstack:  callstack,
    allObjects: allObjects
  }

  return new VM(world)
}

module.exports = VM
