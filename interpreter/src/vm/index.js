import buildWorld from './build_world';

export default class VM {
  constructor(world) {
    this.world = world
  }

  static bootstrap(ast) {
    return new VM(buildWorld(ast))
  }

  currentBinding() {
    return this.world.callstack[this.world.callstack.length-1]
  }

  nextExpression() {
    const statestack = this.world.statestack
    while(!this.world.mainMachine.step()) { }
    return this.currentExpression()
  }

  currentExpression() {
    const id = this.currentBinding().returnValue
    return this.lookup(id)
  }

  setCurrentExpression(value) {
    this.currentBinding().returnValue = value.objectId
  }

  lookup(id) {
    return this.world.allObjects[id]
  }
}
