{DICEFACES} = require './DiceFace.js'
DICEFACESYMBOLS = DICEFACES.symbols

{Player} = require './Player.js'

class Game
  goalTree: undefined
  goalArray: []
  players: [] #private Player[] the players who have joined the game
  playerSocketIds: [] # Matching indices with players
  playerLimit: 2
  goalSetter: undefined
  state:
    unallocated: []
    required: []
    optional: []
    forbidden: []
    currentPlayer: 0 #this tells us the index of the player who's turn it is, and is automatically incremented after each resource move
  

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

  setGoal: (dice) ->  #the function that calls this (everyone.now.receiveGoal() in server.coffee) handles any thrown exceptions
    p = new Parser()
    try
      @goalTree = p.parse(dice)
      @goalArray = dice
      console.log "parsed successfully"
      @start()
    catch e
      console.warn e
    #e = new Evaluator()
    #val = e.evaluate(@goalTree)
    #console.log "Goal parsed and evaluates to #{val}"

  
  addClient: (clientid) ->
    if @players.length == @playerLimit
      throw new Error("Game full")
    else
      newPlayerIndex = @players.length
      @players.push(new Player(newPlayerIndex))
      @playerSocketIds.push(clientid)
      return newPlayerIndex

  isFull: () -> @players.length == @playerLimit
  getNumPlayers: () -> return @players.length
  getFirstTurnPlayer: () -> # return the index of the player who will set the goal
    if !@goalSetter?
      @goalSetter = Math.floor(Math.random() * @players.length) #set a random goalSetter
    @goalSetter

  authenticateMove: (socketId) -> #returns a boolean indicating whether or not the player is authorised to move
    (socketId == @playerSocketIds[@state.currentPlayer])

  start: ->
    @state.currentPlayer = (goalSetter + 1) % @players.length

  nextTurn: () ->
    @state.currentPlayer = (@state.currentPlayer + 1) % @players.length

  resourceExists: (resource) ->
    index = @state.unallocated.indexOf resource
    if (index) == -1
      throw new Error("Resource #{resource} not in Unallocated")
    else
      index

  moveToRequired: (index, clientId) ->
    if !@authenticateMove(clientId)
      throw "Unauthenticated move rejected"
    else if index < 0 || index >= @state.unallocated.length
      throw "Index for move out of bounds"
    else
      @state.required.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @nextTurn()

  moveToOptional: (index, clientId) ->
    if !@authenticateMove(clientId)
      throw "Unauthenticated move rejected"
    else if index < 0 || index >= @state.unallocated.length
      throw "Index for move out of bounds"
    else
      @state.optional.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @nextTurn()

  moveToForbidden: (index, clientId) ->
    if !@authenticateMove(clientId)
      throw "Unauthenticated move rejected"
    else if index < 0 || index >= @state.unallocated.length
      throw "Index for move out of bounds"
    else
      @state.forbidden.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @nextTurn()

module.exports.Game = Game
