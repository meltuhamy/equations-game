numOps = 4
class DICEFACES
  @bracketL    : -8
  @bracketR    : -7
  @sqrt        : -6
  @power       : -5
  @multiply    : -4
  @divide      : -3
  @plus        : -2
  @minus       : -1
  @zero        : 0
  @one         : 1
  @two         : 2
  @three       : 3
  @four        : 4
  @five        : 5
  @six         : 6
  @seven       : 7
  @eight       : 8
  @nine        : 9
  @getString = (face) ->
    if 0 <= face <=0
      "#{face}"
    else
      switch face
        when @bracketL then "("
        when @bracketR then ")"
        when @sqrt     then "sqrt"
        when @power    then "^"
        when @multiply then "*"
        when @divide   then "/"
        when @plus     then "+"
        when @minus    then "-"

module.exports.DICEFACES = DICEFACES;

########### Parser ###########
class Node
  type: undefined     # 'number'/'binop'/'unaryop'
  token: []           # The token. Array because [two three] is "23"
  children: []        # An array of Nodes
  constructor: ({type, token, children}) ->
    @type = type
    @token = token
    @children = if children? then children else []
module.exports.Node = Node

flatten = (node) ->
  str = ""
  if node.children then str += "["
  str+= " "
  str += DICEFACES.getString node.token
  if node.children
    str+=" "
    str += flatten(child) for child in node.children
  str+= " "
  if node.children then str +="]"
  str

prettyPrint = (node) -> console.log flatten(node)
module.exports.prettyPrint = prettyPrint
 
class Evaluator
  getFuncFromOp: (type, op) ->
    if(type == 'binop')
      switch op
        when DICEFACES.plus     then (lhs, rhs) => @evaluate(lhs) + @evaluate(rhs)
        when DICEFACES.minus    then (lhs, rhs) => @evaluate(lhs) - @evaluate(rhs)
        when DICEFACES.multiply then (lhs, rhs) => @evaluate(lhs) * @evaluate(rhs)
        when DICEFACES.divide   then (lhs, rhs) => @evaluate(lhs) / @evaluate(rhs)
    else if(type == 'unaryop')
      switch op
        when DICEFACES.plus     then (rhs) => @evaluate(rhs)
        when DICEFACES.minus    then (rhs) => - @evaluate(rhs)
  evaluate:(node) ->
    switch node.type
      when 'number'
        node.token
      when 'binop'
        func = @getFuncFromOp('binop', node.token)
        func(node.children[0], node.children[1])
      when 'unaryop'
        func = @getFuncFromOp('unaryop', node.token)
        func(node.children[0])

module.exports.Evaluator = Evaluator;

class MathParser
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
    if this.isDigit(c)
      node = new Node(type: "number", token: this.matchNumber())
    else
      throw new Error("UNEXPECTED TOKEN: #{c}")
    node

  isDigit : (c) -> DICEFACES.nine >= c >= DICEFACES.zero
  matchNumber:()-> this.match(this.isDigit)
  
  atEnd: () -> @idx == @expr.length

  match:(matchFn) ->
    result = []
    result.push @expr[@idx++] while !this.atEnd() and matchFn(@expr[@idx])
    result

module.exports.MathParser = MathParser;


########### Game class ###########
class Game
  goalResources: []
  players: []
  playerLimit: 3
  state: {
    unallocated: []
    required: []
    optional: []
    forbidden: []
    currentPlayer: 0
  }

  constructor: (players) ->
    @players = players
    @allocate()

  allocate: ->
    @state.unallocated = []
    ops = 0
    for x in [1..24]  #24 dice rolls
      rand = Math.random()  #get a random number
      if rand < 2/3  #first we decide if the roll yields an operator or a digit
        rand = Math.floor(Math.random() * 10)  #2/3 of the time we get a digit, decided by a new random number
      else  #1/3 of the time we get an operator, again we generate a new random number to decide which operator to use
        rand = Math.floor(Math.random() * - numOps)
        ops++ #we keep track of the number of operators generated so that later we can check if there are enough
      @state.unallocated.push(rand)  #here we add the die to the unallocated resources array
    if (ops < 2) || (ops > 21)  #if there are too few or too many operators, we must roll again
      @allocate()  #do the allocation again

  setGoal: (dice) ->
    @goal = dice

  scan: (dice) ->
    scanned = []
    index = 0
    while index < dice.length
      if 0 <= dice[index] <= 9  #if current element is a number
        if (index < dice.length - 1) && (0 <= dice[index + 1] <= 9) #if next element is a number
          if (index < dice.length - 2) && (0 <= dice[index + 2] <= 9) #if third element is a number
            throw "Numbers limited to 2 digits in a row"
          else
            scanned.push(dice[index] * 10 + dice[index + 1]) #concatenate
            console.log "index before = #{index}"
            index++
            console.log "index after = #{index}"
        else
          scanned.push(dice[index])
      else
        scanned.push(dice[index])
      index++
    scanned

  parse: (pre_tree_array) ->


  addClient: (clientid) ->
    @allocate()
    console.log @state.unallocated
    if @players.length == @playerLimit
      throw new Error("Game full")
    else
      @players.push(new Player(clientid))
      @players.length

  resourceExists: (resource) ->
    index = @state.unallocated.indexOf resource
    if (index) == -1
      throw new Error("Resource #{resource} not in Unallocated")
    else
      index

  moveToRequired: (resource) ->
    try
      index = resourceExists(resource)
      @state.unallocated.splice(index, 1)
      @state.required.push(resource)
    catch e
      console.warn e

  moveToOptional: (resource) ->
    try
      index = resourceExists(resource)
      @state.unallocated.splice(index, 1)
      @state.required.push(resource)
    catch e
      console.warn e

  moveToForbidden: (resource) ->
    try
      index = resourceExists(resource)
      @state.unallocated.splice(index, 1)
      @state.forbidden.push(resource)
    catch e
      console.warn e

  moveToGoal: (resource) ->
    try
      index = resourceExists(resource)
      @state.unallocated.splice(index, 1)
      @state.goalResources.push(resource)
    catch e
      console.warn e

module.exports.Game = Game

class Player
  id: 0
  constructor: (id) ->
    @id = id

module.exports.Player = Player;


