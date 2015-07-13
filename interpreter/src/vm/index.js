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
    // console.log(require("util").inspect(statestack))
    return this.world.machineStack.nextExpression()
  }

  currentExpression() {
    return this.currentBinding().returnValue
  }

  setCurrentExpression(value) {
    this.currentBinding().returnValue = value
  }
}
