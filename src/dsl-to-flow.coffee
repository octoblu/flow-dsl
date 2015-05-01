_             = require 'lodash'
bareBonesFlow = require '../assets/bare-bones-flow'

class DSLToFlow
  constructor: (resources={}, dependencies={})->
    @devices = resources.devices || []
    @nodeTypes = resources.nodeTypes || []
    @uuid = dependencies.uuid ? require 'node-uuid'

  calculatePosition: (node, index) =>
    node.x = 300 * index
    node.y = 0
    node

  convertToFlow: (dslFlow={}) =>
    nodes = _.map dslFlow.nodes || [], @convertNode
    nodes = _.map nodes, @calculatePosition
    flow =
      nodes: nodes
      links: @convertLinks dslFlow.links, nodes
      name: dslFlow.name ? "Flow #{@uuid.v1().substr(0, 6)}"
      zoomScale: 1
      zoomX: 0
      zoomY: 0
    flow

  convertNode: (dslNode={}) =>
    device = _.find @devices, type: dslNode.type
    nodeType = _.find @nodeTypes, type: dslNode.type
    return unless nodeType?
    {uuid, type} = nodeType if nodeType?
    {uuid} = device if device?
    node =
      id: @uuid.v1()
      uuid: uuid
      type: type
      name: nodeType.name
      inputLocations: [
        27.5
      ]
      outputLocations: [
        27.5
      ]
      input: 1
      output: 1

    node.output = nodeType.output if nodeType.output?
    node.input = nodeType.input if nodeType.input?

    defaults = {}
    defaults.channelid = nodeType.channelid if nodeType.channelid?
    defaults.category = nodeType.category if nodeType.category?
    defaults.connector = nodeType.connector if nodeType.connector?
    node.defaults = _.extend {name: node.name, type: node.type}, defaults

    _.extend node, defaults, dslNode

  convertLinks: (links=[], nodes=[]) =>
    getId = (i) => nodes[i]?.id
    _.map links, (link) => toPort: 0, fromPort: 0, to: getId(link.to), from: getId(link.from)


module.exports = DSLToFlow
