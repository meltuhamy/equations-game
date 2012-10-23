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

module.exports.DICEFACES = DICEFACES;

numOps = 2

class GoalNode
  operator: undefined
  e1: undefined
  e2: undefined

class ExpNode
  constructor: ->

class PlusNode extends ExpNode
  exp: undefined
  term: undefined
  constructor: (exp, term) ->
    @exp = exp
    @term = term

class MinusNode extends ExpNode
  exp: undefined
  term: undefined
  constructor: (exp, term) ->
    @exp = exp
    @term = term

class TermNode
  constructor: ->

class MultiNode extends TermNode
  term: undefined
  factor: undefined
  constructor: (term, factor) ->
    @term = term
    @factor = factor

class DivNode extends TermNode
  term: undefined
  factor: undefined
  constructor: (term, factor) ->
    @term = term
    @factor = factor

class FactorNode
  constructor: ->

class PosNode extends FactorNode
  factor: undefined
  constructor: (factor) ->
    @factor = factor

class NegNode extends FactorNode
  factor: undefined
  constructor: (factor) ->
    @factor = factor

class SqrtNode extends FactorNode
  exp: undefined
  constructor: (exp) ->
    @exp = exp

class BracketNode extends FactorNode
  exp: undefined
  constructor: (exp) ->
    @exp = exp

class PowerNode extends FactorNode
  factor: undefined
  exp: undefined
  constructor: (factor, exp) ->
    @factor = factor
    @exp = exp

class Constant extends FactorNode
  value: undefined
  constructor: (value)->
    @value = value 

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


