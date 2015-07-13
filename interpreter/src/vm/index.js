"use strict"
import buildWorld from './build_world'
import {inspect} from 'util'

export default class VM {
  constructor(world) {
    this.world = world
  }

  static bootstrap(ast) {
    return new VM(buildWorld(ast))
  }

  currentBinding() {
    return this.world.currentBinding
  }

  nextExpression() {
    this.world.foundExpression = false
    let i = 0;
    while(!this.world.foundExpression && this.world.machineStack) {
      this.world.machineStack.step()
      if(i++ > 20)
        throw(new Error(`INFINITY! ${this.name()}`))

      while(this.world.machineStack && this.world.machineStack.isFinished())
        this.world.machineStack = this.world.machineStack.parent()
    }

    let hasMachine = !!this.world.machineStack

    return this.currentExpression()
  }

  currentExpression() {
    return this.currentBinding().returnValue
  }

  setCurrentExpression(value) {
    this.currentBinding().returnValue = value
  }
}
