{DiceFace} = require './DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols

class Node
  type: undefined     # 'number'/'binop'/'unaryop'
  token: []           # The token. Array because [two three] is "23"
  children: []        # An array of Nodes
  constructor: ({type, token, children}) ->
    @type = type
    @token = token
    @children = if children? then children else []
module.exports.Node = Node

class ExpressionParser
  constructor: ()->

  parse:(expr) ->
    @expr = expr           # expr is an array of tokens
    @idx  = 0              # start at token 0
    this.handleAddMinus()  # Start with minus because it has lowest precedence

  handleAddMinus: () ->
    child1 = @handleMultiplyDivide()
    node = child1
    c = @expr[@idx]
    while c == DICEFACESYMBOLS.plus or c == DICEFACESYMBOLS.minus
      ++@idx
      child2 = @handleMultiplyDivide()
      node = new Node(type: "binop", token: [c], children: [child1, child2])
      c = @expr[@idx]
      child1 = node
    node
  
  handleMultiplyDivide: () ->
    child1 = @handlePower()
    node = child1
    c = @expr[@idx]
    while c == DICEFACESYMBOLS.multiply or c == DICEFACESYMBOLS.divide
      ++@idx
      child2 = @handlePower()
      node = new Node(type : "binop", token: [c], children: [ child1, child2 ]);
      c = @expr[@idx]
      child1 = node
    node
  handlePower: () ->
    child1 = @handleUnaryOps()
    node = child1
    c = @expr[@idx]
    while c == DICEFACESYMBOLS.power
      ++@idx
      child2 = @handleUnaryOps()
      node = new Node(type : "binop", token: [c], children: [ child1, child2 ]);
      c = @expr[@idx]
      child1 = node
    node
  handleUnaryOps: () ->
    c = @expr[@idx]
    node = {}
    if c == DICEFACESYMBOLS.minus or c == DICEFACESYMBOLS.plus or c == DICEFACESYMBOLS.sqrt
      ++@idx
      node = new Node(type: "unaryop", token: [c], children: [@handleUnaryOps()])
    else
      node = @handleParen()
    node
  handleParen: () ->
    c = @expr[@idx]
    if c == DICEFACESYMBOLS.bracketL
      ++@idx
      if @expr[@idx] == DICEFACESYMBOLS.multiply || @expr[@idx] == DICEFACESYMBOLS.divide || @expr[@idx] == DICEFACESYMBOLS.power || @expr[@idx] == DICEFACESYMBOLS.bracketR then throw new Error("Invalid value after bracket")
      node = @handleAddMinus()
      if @expr[@idx] != DICEFACESYMBOLS.bracketR then throw new Error("Error Unbalanced Parenthesis")
      ++@idx # move past the '('
    else
      node = @atom()
    node
  # Handle atomimic bits, numbers and variables
  atom:() ->
    c = @expr[@idx]
    if this.isNumber(c)
      node = new Node(type: "number", token: this.matchNumber())
    else
      throw new Error("UNEXPECTED TOKEN: #{c}")
    return node

  isNumber : (c) -> c >= DICEFACESYMBOLS.zero 
  matchNumber:()-> this.match(this.isNumber)
  
  atEnd: () -> @idx == @expr.length

  match:(matchFn) ->
    result = []
    numMatched = 0
    result.push @expr[@idx++] while !this.atEnd() and matchFn(@expr[@idx]) and ++numMatched <=2
    if(numMatched >2)
      throw "Can't have more than two digits, maytey"
    result

module.exports.ExpressionParser = ExpressionParser;
