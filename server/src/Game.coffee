{DiceFace} = require './DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols

{ExpressionParser, Node} = require './Parser.js'
{Player} = require './Player.js'
DEBUG = true
class Game
  goalTree: undefined
  goalArray: []
  players: [] #private Player[] the players who have joined the game
  playerSocketIds: [] # Matching indices with players
  playerLimit: 2

  goalSetter: undefined

  # {String} The string id for the nowjs group/room used for players in this game
  nowJsGroupName: ''

  # {Number} The index to the games array
  gameNumber: 0

  # {Boolean} True when the game has started (is full)
  started: false

  state:
    unallocated: []
    required: []
    optional: []
    forbidden: []
    currentPlayer: 0 #this tells us the index of the player who's turn it is, and is automatically incremented after each resource move
  
  constructor: (players, gameNumber) ->
    @players = players
    @gameNumber = gameNumber
    @nowJsGroupName = "game#{gameNumber}"
    @allocate()

  goalHasBeenSet: () ->
    @goalTree? #returns false if goalTree undefined, true otherwise

  allocate: ->
    if DEBUG
      @state.unallocated = [1, DICEFACESYMBOLS.plus, 2, DICEFACESYMBOLS.minus, 3, 4, 5, 6, 7, 8, 9, 0, DICEFACESYMBOLS.divide, 9, 9, 1, 2, 9, 4, 5, DICEFACESYMBOLS.minus, DICEFACESYMBOLS.plus, 2, 4]
    else
      @state.unallocated = []
      ops = 0
      for x in [1..24]  #24 dice rolls
        rand = Math.random()  #get a random number
        if rand < 2/3  #first we decide if the roll yields an operator or a digit
          rand = Math.floor(Math.random() * 10)  #2/3 of the time we get a digit, decided by a new random number
        else  #1/3 of the time we get an operator, again we generate a new random number to decide which operator to use
          rand = Math.floor(Math.random() * - DiceFace.numOps)
          ops++ #we keep track of the number of operators generated so that later we can check if there are enough
        @state.unallocated.push(rand)  #here we add the die to the unallocated resources array
      if (ops < 2) || (ops > 21)  #if there are too few or too many operators, we must roll again
        @allocate()  #do the allocation again


  ###*
   * [setGoal description]
   * @param {Integer} dice [description]
  ###
  setGoal: (dice) ->  #the function that calls this (everyone.now.receiveGoal() in server.coffee) handles any thrown exceptions
    if @goalHasBeenSet() #if goal already set
      throw "Goal already set"
    
    @checkGoal(dice)
    @start()
    #e = new Evaluator()
    #val = e.evaluate(@goalTree)
    #console.log "Goal parsed and evaluates to #{val}"

  ###*
   * This checks whether a goal is a subset of the resources dice and can be parsed.
   * @param  {Integer[]} dice An array of indices to the resource
   * @return {Boolean} True when the goal is valid.
  ###
  checkGoal: (dice) ->
    # First check there are not too many dice in the goal
    #if(dice.length > 6) then throw "Goal uses more than six dice"
    dices = 0
    for i in [0..dice.length]
      if (dice[i] < 24)
        dices++
      i++
    if (dices > 6) then throw "Goal uses more than six dice"
    # Now check that there are not duplicates. We can't use the same dice twice.
    # Also, we check that the indices are in bounds. We can use dice that don't exist.
    diceValues = []
    for i in [0 ... dice.length]
      for j in [i+1 ... dice.length]
        if(dice[i] < 0  || dice[i] > 25) then throw "Goal has out of bounds array index"
        if (dice[i] == dice[j] && i!=j && dice[i] < 24) then throw "Goal uses duplicates dice"
      if dice[i] == 24
        diceValues.push(DiceFace.bracketL)
      else if dice[i] == 25
        diceValues.push(DiceFace.bracketR)
      else
        diceValues.push(@state.unallocated[dice[i]]) 
    # Finally, check that the expression in the dice parses as an expression.
    p = new ExpressionParser()
    @goalTree = p.parse(diceValues)
    @goalArray = diceValues
    return true
  
  ###*
   * Adds a client to the game.
   * @param {Integer} clientid The id of the client given by server
  ###
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
      @goalSetter = if DEBUG then 0 else Math.floor(Math.random() * @players.length) #set a random goalSetter
    @goalSetter

  authenticateMove: (socketId) -> #returns a boolean indicating whether or not the player is authorised to move
    (socketId == @playerSocketIds[@state.currentPlayer])

  start: ->
    @state.currentPlayer = (@goalSetter + 1) % @players.length

  nextTurn: () ->
    @state.currentPlayer = (@state.currentPlayer + 1) % @players.length

  resourceExists: (resource) ->
    index = @state.unallocated.indexOf resource
    if (index) == -1
      throw new Error("Resource #{resource} not in Unallocated")
    else
      index

  moveToRequired: (index, clientId) ->
    if !@goalHasBeenSet()
      throw "Can't move yet, goal has not been set"
    if !@authenticateMove(clientId)
      throw "Unauthenticated move rejected"
    else if index < 0 || index >= @state.unallocated.length
      throw "Index for move out of bounds"
    else
      @state.required.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @nextTurn()

  moveToOptional: (index, clientId) ->
    if !@goalHasBeenSet()
      throw "Can't move yet, goal has not been set"
    if !@authenticateMove(clientId)
      throw "Unauthenticated move rejected"
    else if index < 0 || index >= @state.unallocated.length
      throw "Index for move out of bounds"
    else
      @state.optional.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @nextTurn()

  moveToForbidden: (index, clientId) ->
    if !@goalHasBeenSet()
      throw "Can't move yet, goal has not been set"
    if !@authenticateMove(clientId)
      throw "Unauthenticated move rejected"
    else if index < 0 || index >= @state.unallocated.length
      throw "Index for move out of bounds"
    else
      @state.forbidden.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @nextTurn()

module.exports.Game = Game
