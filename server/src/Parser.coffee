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

  # Handler for '+' and '-' (only the binary versions).
  handleAddMinus: () ->
    child1 = @handleMultiplyDivide() # parses the left hand expression
    node = child1
    c = @expr[@idx]
    while c == DICEFACESYMBOLS.plus or c == DICEFACESYMBOLS.minus # checks if the current operator is '+' or '-' 
      ++@idx
      if @expr[@idx] == DICEFACESYMBOLS.bracketR # detects if a right bracket ')' is wrongly placed.
        ErrorManager.throw(ERRORCODES.parseError, {token: @idx, diceface:c}, "Invalid value before bracket")
      child2 = @handleMultiplyDivide()  # parses the right hand expression
      node = new Node(type: "binop", token: [c], children: [child1, child2])
      c = @expr[@idx]
      child1 = node
    node
  
  # Handler for '*' and '/'.
  handleMultiplyDivide: () ->
    child1 = @handlePower() # parses the left hand expression
    node = child1
    c = @expr[@idx]
    while c == DICEFACESYMBOLS.multiply or c == DICEFACESYMBOLS.divide # checks if the current operator is '*' or '/' 
      ++@idx
      child2 = @handlePower() # parses the right hand expression
      if(c == DICEFACESYMBOLS.divide)
        e = new Evaluator
        if e.evaluate(child2) == 0 #detects division by 0
          ErrorManager.throw(ERRORCODES.parserDivByZero, {token: @idx, diceface:c}, "You can't divide by zero ")
      node = new Node(type : "binop", token: [c], children: [ child1, child2 ]);
      c = @expr[@idx]
      child1 = node
    node

  # Handler for 'power'.
  handlePower: () ->
    child1 = @handleUnaryOps() # parses the left hand expression
    node = child1
    c = @expr[@idx]
    while c == DICEFACESYMBOLS.power # checks if the current operator is a power
      ++@idx
      child2 = @handleUnaryOps() # parses the right hand expression
      node = new Node(type : "binop", token: [c], children: [ child1, child2 ]);
      c = @expr[@idx]
      child1 = node
    node

  # Handler for '+' and '-' (only the unary versions).
  handleUnaryOps: () ->
    c = @expr[@idx]
    node = {}
    if c == DICEFACESYMBOLS.minus or c == DICEFACESYMBOLS.plus or c == DICEFACESYMBOLS.sqrt # checks if ithe current operator is a unary operator
      ++@idx
      if @expr[@idx] == DICEFACESYMBOLS.bracketR ## detects if a right bracket ')' is wrongly placed.
        ErrorManager.throw(ERRORCODES.parseError, {token: @idx, diceface:c}, "Invalid value before bracket")
      if c == DICEFACESYMBOLS.sqrt
        temp = @idx
        e = new Evaluator()
        if e.evaluate(@handleUnaryOps())<0 # detects if a right bracket ')' is wrongly placed.
          ErrorManager.throw(ERRORCODES.parserSqrtNeg, {token: @idx, diceface:c}, "You can't square root a negative")
        @idx = temp
      node = new Node(type: "unaryop", token: [c], children: [@handleUnaryOps()])
    else if c == DICEFACESYMBOLS.multiply or c == DICEFACESYMBOLS.divide or c == DICEFACESYMBOLS.power # detects wrongly placed binary operators
      ErrorManager.throw(ERRORCODES.parseError, {token: @idx, diceface:c}, "This operator isn't allowed to go here")
    else
      node = @handleParen() # parses the expression without the operator
    node

  # Handler for '(' and ')'.
  handleParen: () ->
    c = @expr[@idx]
    if c == DICEFACESYMBOLS.bracketL # checks if the current symbol is a left bracket
      ++@idx
      # detects wrongly placed operators after left bracket
      if @expr[@idx] == DICEFACESYMBOLS.multiply || @expr[@idx] == DICEFACESYMBOLS.divide || @expr[@idx] == DICEFACESYMBOLS.power || @expr[@idx] == DICEFACESYMBOLS.bracketR
        ErrorManager.throw(ERRORCODES.parseError, {token: @idx, diceface:c}, "Invalid value before bracket")
      node = @handleAddMinus() # parses the expression inside the brackets.
      if @expr[@idx] != DICEFACESYMBOLS.bracketR # detects unbalanced bracketing
        ErrorManager.throw(ERRORCODES.parserUnbalancedBrack, {token: @idx, diceface:c}, "Error Unbalanced Parenthesis")
      ++@idx
    else
      node = @atom() # reaches here only if expression is an atom. Parses this atom.
    node

  # Handle atomimic bits, numbers and variables
  atom:() ->
    c = @expr[@idx]
    if @expr[@idx+1]? && @expr[@idx+1] == DICEFACESYMBOLS.bracketL # detects if you have a number before brackets (for multiplication), which isn't allowed in this game
      ErrorManager.throw(ERRORCODES.parserMultBrackWithoutTimes, {token: @idx, diceface:c}, "Invalid syntax. Must use a cross to multiply")
    if this.isNumber(c) # checks if the current token is a number
      node = new Node(type: "number", token: this.matchNumber())
    else if !c? # detects if you finish an equation with an operator
      ErrorManager.throw(ERRORCODES.parseError, {token: @idx-1
        , diceface:c}, "You can't finish with an operator")
    else # for all other errors
      ErrorManager.throw(ERRORCODES.parseError, {token: @idx, diceface:c}, "UNEXPECTED TOKEN: #{c}")
    return node

  # checks if the given value is a number
  isNumber : (c) -> c >= DICEFACESYMBOLS.zero
  # used in match
  matchNumber:()-> this.match(this.isNumber)
  # is the parser at the end of the token array?
  atEnd: () -> @idx == @expr.length

  ###*
   * Used to match up consecutive digits.
   * @param  {Function} matchFn A function integer->bool that must be true for matched digits. 
   * @return {Integer[]} The array of dicefaces if there are no errors with match up digit dice.
  ###
  match:(matchFn) ->
    result = []
    numMatched = 0
    c = @expr[@idx]
    result.push @expr[@idx++] while !this.atEnd() and matchFn(@expr[@idx]) and ++numMatched <=2
    if(numMatched >2 && @isGoal) # prevents using numbers with more than 2 digits when setting the goal
      ErrorManager.throw(ERRORCODES.parserTooManyDigits, {token: @idx, diceface:c, maxdigits:2}, "Can't have more than two digits")
    else if (numMatched >1) # prevents using numbers with more than 1 digit when giving a solution
      ErrorManager.throw(ERRORCODES.parserTooManyDigits, {token: @idx, diceface:c, maxdigits:1}, "Can't have more than one digit")
    result


  # Used in flatten - used to remove redundant brackets
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
    result = []  #initialise the expression to an empty list
    if node.type == 'binop'
    #if the current root of the tree is a binary operator then we
    #recursively flatten the left and right hand expressions
      leftResult = @flatten(node.children[0])
      rightResult = @flatten(node.children[1])
      #if the precedence of the left hand subtree is less than the current operator
      #then we bracket it
      if @precedence(node.children[0]) < @precedence(node)
        leftResult.push(DICEFACESYMBOLS.bracketL)
        leftResult.concat([DICEFACESYMBOLS.bracketR])
      #same for right hand subtree
      if @precedence(node.children[1]) < @precedence(node)
        rightResult.push(DICEFACESYMBOLS.bracketL)
        rightResult.concat([DICEFACESYMBOLS.bracketR])
      #now we simply concatnate the results and return
      result = leftResult.concat(node.token,rightResult)
      return result
    else if node.type == 'unaryop'
      #if unary operator, then just add the operator to the output list and
      #recursively flatten the expression to which the operator is applied
      return result.concat(node.token, @flatten(node.children[0]))
    else if node.type == 'number'
      #if the node is a number, just return it's token
      return node.token



module.exports.ExpressionParser = ExpressionParser;
