{DICEFACES} = require './DiceFace.js'

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
    while c == DICEFACES.plus or c == DICEFACES.minus
      ++@idx
      child2 = @handleMultiplyDivide()
      node = new Node(type: "binop", token: [c], children: [child1, child2])
      c = @expr[@idx]
      child1 = node
    node
  
  handleMultiplyDivide: () ->
    child1 = @handleUnaryOps()
    node = child1
    c = @expr[@idx]
    while c == DICEFACES.multiply or c == DICEFACES.divide
      ++@idx
      child2 = @handleUnaryOps()
      node = new Node(type : "binop", token: [c], children: [ child1, child2 ]);
      c = @expr[@idx]
      child1 = node
    node
  handleUnaryOps: () ->
    c = @expr[@idx]
    node = {}
    if c == DICEFACES.minus or c == DICEFACES.plus
      ++@idx
      node = new Node(type: "unaryop", token: [c], children: [@handleUnaryOps()])
    else
      node = @handleParen()
    node
  handleParen: () ->
    c = @expr[@idx]
    if c == DICEFACES.bracketL
      ++@idx
      node = @handleAddMinus()
      if @expr[@idx] != DICEFACES.bracketR then throw new Error("Error Unbalanced Parenthesis")
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

  isNumber : (c) -> c >= DICEFACES.zero
  matchNumber:()-> this.match(this.isNumber)
  
  atEnd: () -> @idx == @expr.length

  match:(matchFn) ->
    result = []
    result.push @expr[@idx++] while !this.atEnd() and matchFn(@expr[@idx])
    result

module.exports.ExpressionParser = ExpressionParser;
