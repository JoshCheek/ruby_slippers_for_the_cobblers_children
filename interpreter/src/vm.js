var VM = function(world) {
  this.world = world
}

VM.prototype.currentBinding = function() {
  return this.world.callstack[this.world.callstack.length-1]
}

VM.prototype.currentExpression = function() {
  return this.world.currentBinding.returnValue
}

VM.prototype.nextExpression = function() {
  let rTrue = this.world.rTrue
  let tmpBullshit = function(ast) {
    switch(ast.type) {
      case "true": return rTrue;
      default: throw(`Unexpected ast: ${ast}`)
    }
  }


  return tmpBullshit(this.world.ast)
}


VM.bootstrap = function(ast) {
  // All Objects
  let allObjects = {}
  allObjects.size = function() { Object.keys(this).length }

  let nextObjectId = 1
  allObjects.track = function(toTrack) {
    toTrack.objectId = nextObjectId
    ++nextObjectId
    return toTrack
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

  // callstack
  let main = instantiate(rObject)
  let toplevelBinding = {
    localVariables: {},
    self:           main.objectId,
    returnValue:    rTrue.objectId,
  }
  let callstack = [toplevelBinding]

  // put it all together
  let world = {
    ast:       ast,
    rTrue:     rTrue,
    callstack: callstack,
  }

  return new VM(world)
}

module.exports = VM
