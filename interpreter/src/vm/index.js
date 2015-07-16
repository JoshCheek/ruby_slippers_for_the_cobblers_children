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
    return this.world.$currentBinding
  }

  nextExpression() {
    this.world.$foundExpression = false
    while(!this.world.$foundExpression && this.world.$machineStack) {
      this.world.$machineStack.step()

      while(this.world.$machineStack && this.world.$machineStack.isFinished())
        this.world.$machineStack = this.world.$machineStack.parent()
    }

    let hasMachine = !!this.world.$machineStack

    return this.currentExpression()
  }

  currentExpression() {
    return this.currentBinding().returnValue
  }

  setCurrentExpression(value) {
    this.currentBinding().returnValue = value
  }
}
