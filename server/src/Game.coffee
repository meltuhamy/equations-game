{DICEFACES} = require './DiceFace.js'
DICEFACESYMBOLS = DICEFACES.symbols

{Player} = require './Player.js'

class Game
  goalTree: undefined
  players: [] #private Player[] the players who have joined the game
  playerLimit: 2
  state:
    unallocated: []
    required: []
    optional: []
    forbidden: []
    currentPlayer: 0
  

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
        rand = Math.floor(Math.random() * - DICEFACES.numOps)
        ops++ #we keep track of the number of operators generated so that later we can check if there are enough
      @state.unallocated.push(rand)  #here we add the die to the unallocated resources array
    if (ops < 2) || (ops > 21)  #if there are too few or too many operators, we must roll again
      @allocate()  #do the allocation again

  setGoal: (dice) ->
    scanned = @scan(dice)
    @goalTree = parser.parse(scanned)
    #e = new Evaluator()
    #val = e.evaluate(@goalTree)
    #console.log "Goal parsed and evaluates to #{val}"


  addClient: (clientid) ->
    if @players.length == @playerLimit
      throw new Error("Game full")
    else
      @players.push(new Player(clientid))
      @players.length

  isFull: () -> @players.length == @playerLimit
  getNumPlayers: () -> return @players.length
  getFirstTurnPlayer: () -> 0 # return the index of the player who will set the goal

  nextTurn: () ->
    @state.currentPlayer = (@state.currentPlayer + 1) % @players.length
    console.log @state.currentPlayer

  resourceExists: (resource) ->
    index = @state.unallocated.indexOf resource
    if (index) == -1
      throw new Error("Resource #{resource} not in Unallocated")
    else
      index

  moveToRequired: (resource) ->
    try
      index = @resourceExists(resource)
      @state.unallocated.splice(index, 1)
      @state.required.push(resource)
      @nextTurn()
    catch e
      console.warn e

  moveToOptional: (resource) ->
    try
      index = @resourceExists(resource)
      @state.unallocated.splice(index, 1)
      @state.optional.push(resource)
      @nextTurn()
    catch e
      console.warn e

  moveToForbidden: (resource) ->
    try
      index = @resourceExists(resource)
      @state.unallocated.splice(index, 1)
      @state.forbidden.push(resource)
      @nextTurn()
    catch e
      console.warn e

module.exports.Game = Game
