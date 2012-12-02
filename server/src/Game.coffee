{DiceFace} = require './DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols

{ExpressionParser, Node} = require './Parser.js'
{Player} = require './Player.js'
{Evaluator} = require './Evaluator.js'
DEBUG = true


class Game

  goalTree: undefined
  goalArray: []
  goalValue: undefined

  # {String} The name of the game as it appears on the lobby etc.
  name: ''

  # {Player[]} An array of players who have joined the game
  players: []

  # {Number} The nowjs sockets for players. These match up index-by-index with players array
  playerSocketIds: []

  # {Number} The maximum number of players allow in the game.
  playerLimit: 2

  # {Number} An index to players array. Player who sets the goal (takes the goal setting turn)
  goalSetter: undefined

  # {String} The string id for the nowjs group/room used for players in this game
  nowJsGroupName: ''

  # {Number} The index to the games array
  gameNumber: 0

  # {Boolean} True when the game has started (is full)
  started: false

  # {Number} The dice that will be used throughout the game. An array of diceface magic numbers.
  globalDice: []

  # {Boolean} Has the turn taking halted for a challenge?
  challengeMode: false

  # {Boolean} Differentiates between now and never challenges
  challengeModeNow: false

  # {Number} the index of the player array for the challenger
  challenger: undefined

  

  submittedSolutions: []

  rightAnswers: []

  ###*
   * The game state.
   * **************
   * IF YOU CHANGE THIS, CHANGE client/Game.coffee
   * **************
  ###
  state: undefined


  
  constructor: (@gameNumber, @name, gameSize) ->
    # Initalise all variables so that they're object (not prototype) specfific
    @goalTree = undefined
    @goalArray = []
    @goalValue = undefined
    @name= ''
    @players= []
    @playerSocketIds= []
    @goalSetter= undefined
    @nowJsGroupName= ''
    @challenger= undefined
    @submittedSolutions= []
    @rightAnswers= []

    ###*
     * The game state.
     * **************
     * IF YOU CHANGE THIS, CHANGE client/Game.coffee
     * **************
    ###
    @state=
      unallocated: []
      required: []
      optional: []
      forbidden: []
      # index of player whose turn it is. incremented after each resource move
      currentPlayer: 0
      # What turn number is it? This increments after a turn has been made. 
      # The dice setting has turnNumber = 0. The first turn to move dice has turnNumber = 1. 
      #turnNumber
      # {Number[]} array of indices to player array of the players need to submit a solution
      possiblePlayers: []
      # {Number[]} array of indices to player array of the players are not submitting a solution
      impossiblePlayers: []
      # {Date} The Unix timestamp of when the current turn started
      turnStartTime: undefined
      # {Number} The duration of the current turn in seconds
      turnDuration: undefined



    @gameNumber = gameNumber
    @name = name
    @gameSize = gameSize
    if gameSize?
      if gameSize > 2 then @playerLimit = gameSize
    @nowJsGroupName = "game#{gameNumber}"
    @allocate()


  goalHasBeenSet: () ->
    @goalTree? #returns false if goalTree undefined, true otherwise


  # Convert a player id to a socketid and vica versa
  getPlayerIdBySocket: (socket) -> @playerSocketIds.indexOf(socket)
  getPlayerSocketById: (id) -> @playerSocketIds[id]


  ###*
   * Spawns the global array. Uses a random distribution to work out the dice for the game.
  ###
  allocate: ->
    if DEBUG
      # TODO move this ugly thing to a settings file
      @globalDice = [1, DICEFACESYMBOLS.plus, 2, DICEFACESYMBOLS.minus, 3, 4, 5, 6, 7, 8, 9, 0, DICEFACESYMBOLS.divide, 9, 9, 1, 2, 9, 4, 5, DICEFACESYMBOLS.minus, DICEFACESYMBOLS.plus, 2, 4]
    else
      ops = 0
      for x in [1..24]  #24 dice rolls
        rand = Math.random()  #get a random number
        if rand < 2/3  #first we decide if the roll yields an operator or a digit
          rand = Math.floor(Math.random() * 10)  #2/3 of the time we get a digit, decided by a new random number
        else  #1/3 of the time we get an operator, again we generate a new random number to decide which operator to use
          rand = Math.floor(Math.random() * - DiceFace.numOps)
          ops++ #we keep track of the number of operators generated so that later we can check if there are enough
        @globalDice.push(rand)  #here we add the die to the global dice array
      if (ops < 2) || (ops > 21)  #if there are too few or too many operators, we must roll again
        @allocate()  #do the allocation again


  ###*
   * [setGoal description]
   * the function that calls this (everyone.now.receiveGoal() in server.coffee) handles any thrown exceptions
   * @param {Integer} dice [description]
  ###
  setGoal: (dice, turnEndCallback) ->  
    if @goalHasBeenSet() #if goal already set
      throw "Goal already set"
    
    @checkGoal(dice)
    @start(turnEndCallback)
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
      if (dice[i] >= 0)
        dices++
      i++
    if (dices > 6) then throw "Goal uses more than six dice"
    # Now check that there are not duplicates. We can't use the same dice twice.
    # Also, we check that the indices are in bounds. We can use dice that don't exist.
    numGlobalDice = @globalDice.length

    # Copy global dice into unallocated using split (which is [..] in coffeescript)
    # Later, we will remove from unallocatedTemp as we work out which dice the dice setter chose 
    # for the goal in the loops below. See line (*). The final v. will be state.unallocated.
    unallocatedTemp = [0...numGlobalDice]


    diceValues = []
    for i in [0 ... dice.length]
      for j in [i+1 ... dice.length]
        if (dice[i] < -2  || dice[i] >= numGlobalDice) then throw "Goal has out of bounds array index"
        if (dice[i] == dice[j] && i!=j  && dice[i] >= 0) then throw "Goal uses duplicates dice"
      if dice[i] == -1
        diceValues.push(DICEFACESYMBOLS.bracketL)
      else if dice[i] == -2
        diceValues.push(DICEFACESYMBOLS.bracketR)
      else
        diceValues.push(@globalDice[dice[i]])
        unallocatedTemp.splice(dice[i], 1) # Remove the dice from unallocated.

    @state.unallocated = unallocatedTemp

    # Finally, check that the expression in the dice parses as an expression.
    p = new ExpressionParser()
    @goalTree = p.parse(diceValues)
    @goalArray = diceValues

    e = new Evaluator()
    @goalValue = e.evaluate(@goalArray)

    return true
  
  ###*
   * Adds a client to the game.
   * @param {Integer} clientid The nowjs unique id of the player
   * @return {Integer} The index of the players array for the newly added player
  ###
  addClient: (clientid) ->
    if @players.length == @playerLimit
      throw new Error("Game full")
    else
      newPlayerIndex = @players.length
      @players.push(new Player(newPlayerIndex, 'James'))
      @playerSocketIds.push(clientid)
      return newPlayerIndex


  isFull: () -> @players.length == @playerLimit
  getNumPlayers: () -> return @players.length

  
  ###*
   * Get the index of the player who moves the first dice from unallocated
   * @return {[Integer} An index to the players array
  ###
  getFirstTurnPlayerId: () -> 
    if !@goalSetter? then @getGoalSetterPlayerId()
    return @goalSetter+1%@players.length
  # If we want to get his socket id instead of the player array index
  getFirstTurnPlayerSocketId: () -> @getPlayerSocketById(@getFirstTurnPlayerId())



  ###*
   * Return the index of the player who will set the goal
   * @return {[Integer} An index to the players array
  ###
  getGoalSetterPlayerId: () ->
    if !@goalSetter?
      @goalSetter = if DEBUG then 0 else Math.floor(Math.random() * @players.length) #set a random goalSetter
    @goalSetter


  ###*
   * See if this player is allowed to make this move.
   * @param  {[type]} socketId The nowjs socket id of the player.
   * @return {[type]}          Return True if it is this player's turn to move 
  ###
  authenticateMove: (socketId) -> #returns a boolean 
    (socketId == @playerSocketIds[@state.currentPlayer])

  validateChallenge: (socketId) ->
    (socketId != @playerSocketIds[((@state.currentPlayer-1)+@players.length)%@players.length])


  goalStart: (turnEndCallback) ->
    @started = true
    # TODO: add callback for timer


  start: (turnEndCallback) ->
    @state.currentPlayer = (@goalSetter+1)%@players.length
    @resetTurnTimer(7, turnEndCallback)
    
    

  nextTurn: (turnEndCallback) ->
    @state.currentPlayer = (@state.currentPlayer+1)%@players.length
    @resetTurnTimer(7, turnEndCallback)
    
  

  ###*
   * When the turn has changed reset the timer back to the start.  
   * @param  {Integer} turnSeconds       The number of seconds until the each of the turn.
   * @param  {Function} endOfTurnTimeFunc This function is called when the time is up.
  ###
  resetTurnTimer: (turnSeconds, turnEndCallback) ->
    @state.turnStartTime = Date.now()
    @state.turnDuration = turnSeconds
    clearInterval(@turnTimer)
    # Has the player completed his turn BEFORE end of time?
    thisReference = this
    @turnTimer = setInterval(->
      thisReference.handleTimeOut(turnEndCallback)
      if(turnEndCallback?) then turnEndCallback() else console.log "TURN OVER"
    , turnSeconds*1000)


  handleTimeOut: (turnEndCallback) ->
    if(@challengeMode)
      # Move players into the option that makes them submit a solution
      if(!@allDecisionsMade())
        console.log "NOT EVERYONE MADE DECISION"
        for p in @players
          index = p.index
          if((index not in @state.possiblePlayers) and (index not in @state.impossiblePlayers))
            @submitPossible(@getPlayerSocketById(index))
    else
      @nextTurn(turnEndCallback)




  checkValidAllocationMove: (index, clientId) ->
    if @challengeMode
      throw "Can't move during challenge mode"
    if !@goalHasBeenSet()
      throw "Can't move yet, goal has not been set"
    if !@authenticateMove(clientId)
      throw "Not your turn"
    else if index < 0 || index >= @state.unallocated.length
      throw "Index for move out of bounds"
    else true

  moveToRequired: (index, clientId, turnEndCallback) ->
    if(@checkValidAllocationMove(index, clientId))
      @state.required.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @nextTurn(turnEndCallback)

  moveToOptional: (index, clientId, turnEndCallback) ->
   if(@checkValidAllocationMove(index, clientId))
      @state.optional.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @nextTurn(turnEndCallback)

  moveToForbidden: (index, clientId, turnEndCallback) ->
    if(@checkValidAllocationMove(index, clientId))
      @state.forbidden.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @nextTurn(turnEndCallback)

  ###*
   * Attempt to g into the decide stage of a now challenge.
   * @param  {Integer} clientId The nowjs unqiue id for client
  ###
  nowChallenge: (clientId, turnEndCallback) ->
    @challengeMode = true
    @challengeModeNow = true
    @challenger = clientId
    @state.possiblePlayers.push(@getPlayerIdBySocket(clientId))
    @resetTurnTimer(9, turnEndCallback)


  neverChallenge: (clientId, turnEndCallback) ->
    @challengeMode = true
    @challengeModeNow = false
    @challenger = clientId
    @state.impossiblePlayers.push(@getPlayerIdBySocket(clientId))
    @resetTurnTimer(9, turnEndCallback)

  submitPossible: (clientId, turnEndCallback) ->
    @checkChallengeDecision()
    @state.possiblePlayers.push(@getPlayerIdBySocket(clientId))
    if(@allDecisionsMade())
      # Give 40 seconds for the solutions turn
      @resetTurnTimer(40, turnEndCallback)

  submitImpossible: (clientId, turnEndCallback) ->
    @checkChallengeDecision()
    @state.impossiblePlayers.push(@getPlayerIdBySocket(clientId))
    if(@allDecisionsMade())
      # Give 40 seconds for the solutions turn
      @resetTurnTimer(7, turnEndCallback)


  checkChallengeDecision:(clientId) ->
    if !@challengeMode
      throw "Can't submit opinion, not currently challenge mode"
    if (clientId in @state.possiblePlayers) || (clientId in @state.impossiblePlayers)
      throw "Already stated your opinion"


  # Check if everyone has submitted their decisions for the decision making turn
  allDecisionsMade:() -> (@players.length == (@state.possiblePlayers.length + @state.impossiblePlayers.length))




  ###*
   * @param  {[type]} clientId      [description]
   * @param  {[type]} dice An array of indices to the globalArray for the answer.
  ###
  submitSolution: (socketId, dice) ->
    if !@challengeMode then throw "Not in challenge mode"
    playerid = @getPlayerIdBySocket(socketId)
    #console.log "Player #{playerid} trying to submit solution #{dice}, clientid = #{socketId}"
    #console.log @submittedSolutions
    # If he hasn't already submitted a solution..
    # console.log @submittedSolutions[playerid]
    if (playerid in @state.possiblePlayers)
      if (@submittedSolutions[playerid]?) then throw "Player #{socketId} already submitted solution which is: #{@submittedSolutions[playerid]}"
      # Check if the solution submitted is valid
      diceValues = []
      numRequiredInAns = 0
      numUnallocatedInAns = 0
      numGlobalDice = @globalDice.length
      for i in [0 ... dice.length]
        for j in [i+1 ... dice.length]
          if (dice[i] < -2  || dice[i] >= numGlobalDice) then throw "Solution has out of bounds array index"
          if (dice[i] == dice[j] && i!=j  && dice[i] >= 0) then throw "Solution uses duplicate dice"
        if dice[i] == -1
          diceValues.push(DICEFACESYMBOLS.bracketL)
        else if dice[i] == -2
          diceValues.push(DICEFACESYMBOLS.bracketR)
        else
          diceValues.push(@globalDice[dice[i]])
        if(dice[i] in @state.forbidden) then throw "Solution uses dice from forbidden"
        if(dice[i] in @state.required) then numRequiredInAns++
        if(dice[i] in @state.unallocated) then numUnallocatedInAns++

      if(numRequiredInAns < @state.required.length) then throw "Solution doesn't use all dice from required"
      if(numUnallocatedInAns > 1 && @challengeModeNow) then throw "Solution doesn't use one dice from unallocated"

      # Everything ok-doky index wise. Now let's check it parses and gives the same value.
      e = new Evaluator
      p = new ExpressionParser
      # TODO separate out and wrap in try catch
      submissionValue = e.evaluate(p.parse(diceValues))
      # Ok it does. So add it to the submitted solutions list
      @rightAnswers[playerid] = (@goalValue == submissionValue)
      @submittedSolutions[playerid] = dice
    else
      playerid = @getPlayerIdBySocket(socketId)
      throw "Client not in 'possible' list"
    for i in [0...@state.possiblePlayers]
      if @submittedSolutions[i] == undefined
        return
    @scoreAdder()
    #@nextRound()

      
scoreAdder: ->
  answerExists = false
  for playerid in [0 ... @players.length]
    if @rightAnswers[playerid] then answerExists = true
  if answerExists
    for playerid in [0 ... @players.length]
      if playerid in @possiblePlayers then state.playerScores[playerid] += 2
      if @rightAnswers[playerid] then state.playerScores[playerid] += 2
      if @challenger == playerid && playerid in @possiblePlayers then state.playerScores[playerid] += 2
  else
    for playerid in [0 ... @players.length]
      if playerid in @impossiblePlayers then state.playerScores[playerid] += 2
      if @challenger == playerid && playerid in @impossiblePlayers then state.playerScores[playerid] += 2
    

nextRound: ->
  @goalTree = undefined
  @goalArray = []
  @goalValue = undefined
  #players: []
  #playerSocketIds: []
  #playerLimit: 2
  @goalSetter = undefined
  #nowJsGroupName: ''
  #gameNumber: 0
  @started = false
  @globalDice = []
  @challengeMode = false
  @challengeModeNow = false
  @challenger = undefined
  @submittedSolutions = []
  @rightAnswers = []
  @state.unallocated = []
  @state.playerScores = []
  @state.required = []
  @state.optional = []
  @state.forbidden = []
  @state.currentPlayer = 0
  @state.possiblePlayers = []
  @state.impossiblePlayers = []











      

      

module.exports.Game = Game
