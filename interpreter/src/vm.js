var VM = function(world) {
  this.world = world
}

VM.bootstrap = function(ast) {
  let instantiate = function(klass) {
    return { class: klass, instance_variables: {} }
  }

  let rClass = {
    instance_variables: {},
  }
  rClass.class = rClass

  let rTrueClass = instantiate(rClass)

  let world = {
    rTrue: instantiate(rTrueClass),
  }

  return new VM(world)
}

module.exports = VM
