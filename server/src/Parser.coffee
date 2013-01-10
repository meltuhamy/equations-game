{DiceFace} = require './DiceFace.js'
{Evaluator} = require './Evaluator.js'
DICEFACESYMBOLS = DiceFace.symbols

{ErrorManager}  = require './ErrorManager.js'
ERRORCODES = ErrorManager.codes

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
    @isGoal = undefined

  parse:(expr, goalFlag) ->
    @isGoal = goalFlag
    @expr = expr           # expr is an array of tokens
    @idx  = 0              # start at token 0
    this.handleAddMinus()  # Start with minus because it has lowest precedence

  handleAddMinus: () ->
    child1 = @handleMultiplyDivide()
    node = child1
    c = @expr[@idx]
    while c == DICEFACESYMBOLS.plus or c == DICEFACESYMBOLS.minus
      ++@idx
      if @expr[@idx] == DICEFACESYMBOLS.bracketR
        ErrorManager.throw(ERRORCODES.parseError, {token: @idx, diceface:c}, "Invalid value before bracket")
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
      if(c == DICEFACESYMBOLS.divide)
        e = new Evaluator
        if e.evaluate(child2) == 0 
          ErrorManager.throw(ERRORCODES.parserDivByZero, {token: @idx, diceface:c}, "You can't divide by zero you idiot")
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
      if @expr[@idx] == DICEFACESYMBOLS.bracketR
        ErrorManager.throw(ERRORCODES.parseError, {token: @idx, diceface:c}, "Invalid value before bracket")
      if c == DICEFACESYMBOLS.sqrt
        temp = @idx
        e = new Evaluator()
        if e.evaluate(@handleUnaryOps())<0
          ErrorManager.throw(ERRORCODES.parserSqrtNeg, {token: @idx, diceface:c}, "You can't square root a negative")
        @idx = temp
      node = new Node(type: "unaryop", token: [c], children: [@handleUnaryOps()])
    else
      node = @handleParen()
    node
  handleParen: () ->
    c = @expr[@idx]
    if c == DICEFACESYMBOLS.bracketL
      ++@idx
      if @expr[@idx] == DICEFACESYMBOLS.multiply || @expr[@idx] == DICEFACESYMBOLS.divide || @expr[@idx] == DICEFACESYMBOLS.power || @expr[@idx] == DICEFACESYMBOLS.bracketR
        ErrorManager.throw(ERRORCODES.parseError, {token: @idx, diceface:c}, "Invalid value before bracket")
      node = @handleAddMinus()
      if @expr[@idx] != DICEFACESYMBOLS.bracketR
        ErrorManager.throw(ERRORCODES.parserUnbalancedBrack, {token: @idx, diceface:c}, "Error Unbalanced Parenthesis")
      ++@idx # move past the '('
    else
      node = @atom()
    node
  # Handle atomimic bits, numbers and variables
  atom:() ->
    c = @expr[@idx]
    if @expr[@idx+1]? && @expr[@idx+1] == DICEFACESYMBOLS.bracketL 
      ErrorManager.throw(ERRORCODES.parserMultBrackWithoutTimes, {token: @idx, diceface:c}, "Invalid syntax. Must use a cross to multiply")
    if this.isNumber(c)
      node = new Node(type: "number", token: this.matchNumber())
    else if !c?
      ErrorManager.throw(ERRORCODES.parseError, {token: @idx-1
        , diceface:c}, "You can't finish with an operator")
    else
      ErrorManager.throw(ERRORCODES.parseError, {token: @idx, diceface:c}, "UNEXPECTED TOKEN: #{c}")
    return node

  isNumber : (c) -> c >= DICEFACESYMBOLS.zero 
  matchNumber:()-> this.match(this.isNumber)
  
  atEnd: () -> @idx == @expr.length

  match:(matchFn) ->
    result = []
    numMatched = 0
    result.push @expr[@idx++] while !this.atEnd() and matchFn(@expr[@idx]) and ++numMatched <=2
    if(numMatched >2 && @isGoal)
      ErrorManager.throw(ERRORCODES.parserTooManyDigits, {token: @idx, diceface:c, maxdigits:2}, "Can't have more than two digits, maytey")
    else if (numMatched >1)
      ErrorManager.throw(ERRORCODES.parserTooManyDigits, {token: @idx, diceface:c, maxdigits:1}, "Can't have more than one digit, maytey")
    result
    #if(numMatched >2 && @isGoal)
      #throw "Can't have more than two digits, maytey"
    #else if (numMatched >1)
      #console.log @isGoal
      #throw "Can't have more than one digit, maytey"
    #result

  precedence: (node) ->
    if node.type == 'unaryop'
      return 4
    else
      switch node.token[0]
        when DICEFACESYMBOLS.plus then 1
        when DICEFACESYMBOLS.minus then 1
        when DICEFACESYMBOLS.divide then 2
        when DICEFACESYMBOLS.multiply then 2
        when DICEFACESYMBOLS.power then 3

  flatten: (node) ->
    result = []
    if node.type == 'binop'
      leftResult = @flatten(node.children[0])
      rightResult = @flatten(node.children[1])
      if @precedence(node.children[0]) < @precedence(node)
        leftResult.push(DICEFACESYMBOLS.bracketL)
        leftResult.concat([DICEFACESYMBOLS.bracketR])
      if @precedence(node.children[1]) < @precedence(node)
        rightResult.push(DICEFACESYMBOLS.bracketL)
        rightResult.concat([DICEFACESYMBOLS.bracketR])
      result = leftResult.concat(node.token,rightResult)
      return result
    else if node.type == 'unaryop'
      return result.concat(node.token, @flatten(node.children[0]))
    else if node.type == 'number'
      return node.token



module.exports.ExpressionParser = ExpressionParser;
