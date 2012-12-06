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

    @started = false

    @rightAnswers = []
    @answerExists = false
    @challengePoints = []
    @decisionPoints = []
    @solutionPoints = []


    ###*
     * The game state.
     * **************
     * IF YOU CHANGE THIS, CHANGE client/Game.coffee
     * **************
    ###
    @state =
      unallocated: []
      required: []
      optional: []
      forbidden: []
      # index of player whose turn it is. incremented after each resource move
      currentPlayer: 0
      # What turn number is it? This increments after a turn has been made. 
      # The dice setting has turnNumber = 0. The first turn to move dice has turnNumber = 1. 
      turnNumber: 0
      # {Number[]} array of indices to player array of the players need to submit a solution
      possiblePlayers: []
      # {Number[]} array of indices to player array of the players are not submitting a solution
      impossiblePlayers: []
      # {Date} The Unix timestamp of when the current turn started
      turnStartTime: undefined
      # {Number} The duration of the current turn in seconds
      turnDuration: undefined
      playerScores: []
      # The player array indices of players who ready-ed themselves for the next round.
      readyForNextRound: []
    



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


  throwError: (errorNumber, jsonParams, errorMessage) ->
    error = new Error(errorMessage)
    error.number = errorNumber
    if(jsonParams?) then error.params = jsonParams
    error.emsg = errorMessage
    throw error

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
    @goalTree = p.parse(diceValues, true)
    result = []
    flattened = p.flatten(@goalTree)
    for i in [0...flattened.length]
      while dice[0] == -1 || dice[0] == -2
        dice.splice(0,1)
      result = result.concat(dice[0])
      dice.splice(0,1)
    @goalArray = result    
    e = new Evaluator()
    @goalValue = e.evaluate(@goalTree)

    return true
  
  ###*
   * Adds a client to the game.
   * @param {Integer} clientid The nowjs unique id of the player
   * @return {Integer} The index of the players array for the newly added player
  ###
  addClient: (clientid) ->
    if @players.length == @playerLimit || @started
      throw new Error("Game full or already started")
    else
      newPlayerIndex = @players.length
      @players.push(new Player(newPlayerIndex, 'James'))
      @playerSocketIds.push(clientid)
      @state.playerScores[newPlayerIndex] = 0
      return newPlayerIndex

  removeClient: (clientid) ->
    console.log "Removing from client"
    console.log @players.length
    if @players.length == 2
      @restartGame()
    else #now we need to update players and playersocketIds
      index = @getPlayerIdBySocket(clientid)
      @players.splice(index, 1)
      @playerSocketIds.splice(index,1)
      @state.playerScores.splice(index, 1)
      #now we update possiblePlayers, impossiblePlayers and readyForNextRound arrays in state
      for i in [0...@state.possiblePlayers.length]
        if @state.possiblePlayers[i] == index
          @state.possiblePlayers.splice(i,1)
        if i == @state.possiblePlayers.length - 1
          break
        if @state.possiblePlayers[i] > index
          @state.possiblePlayers[i]--

      for i in [0...@state.impossiblePlayers.length]
        if @state.impossiblePlayers[i] == index
          @state.impossiblePlayers.splice(i,1)
        if i == @state.impossiblePlayers.length - 1
          break
        if @state.impossiblePlayers[i] > index
          @state.impossiblePlayers[i]--

      for i in [0...@state.readyForNextRound.length]
        if @state.readyForNextRound[i] == index
          @state.readyForNextRound.splice(i,1)
        if i == @state.readyForNextRound.length - 1
          break
        if @state.readyForNextRound[i] > index
          @state.readyForNextRound[i]--

      if @state.currentPlayer == index
        @state.currentPlayer = @players.length
      return index



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
    @state.turnNumber = 1
    @resetTurnTimer(7, turnEndCallback)
    
    

  nextTurn: (turnEndCallback) ->
    if @started
      @state.currentPlayer = (@state.currentPlayer+1)%@players.length
      @state.turnNumber += 1
      @resetTurnTimer(7, turnEndCallback)
    else
      clearInterval(@turnTimer)
    
  

  ###*
   * When the turn has changed reset the timer back to the start.  
   * @param  {Integer} turnSeconds       The number of seconds until the each of the turn.
   * @param  {Function} endOfTurnTimeFunc This function is called when the time is up.
  ###
  resetTurnTimer: (turnSeconds, turnEndCallback) ->
    if @started
      @state.turnStartTime = Date.now()
      @state.turnDuration = turnSeconds
      clearInterval(@turnTimer)
      # Has the player completed his turn BEFORE end of time?
      thisReference = this
      @turnTimer = setInterval(->
        thisReference.handleTimeOut(turnEndCallback)
        if(turnEndCallback?) then turnEndCallback() else console.log "TURN OVER"
      , turnSeconds*1000)
    else
      clearInterval(@turnTimer)


  handleTimeOut: (turnEndCallback) ->
    if @started
      if @challengeMode
        # Move players into the option that makes them submit a solution
        if(!@allDecisionsMade())
          console.log "NOT EVERYONE MADE DECISION"
          for p in @players
            index = p.index
            if((index not in @state.possiblePlayers) and (index not in @state.impossiblePlayers))
              @submitPossible(@getPlayerSocketById(index))
      else
        @nextTurn(turnEndCallback)
    else
      clearInterval(@turnTimer)




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
    @challenger = @getPlayerIdBySocket(clientId)
    @state.possiblePlayers.push(@getPlayerIdBySocket(clientId))
    @resetTurnTimer(9, turnEndCallback)


  neverChallenge: (clientId, turnEndCallback) ->
    @challengeMode = true
    @challengeModeNow = false
    @challenger = @getPlayerIdBySocket(clientId)
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
      @resetTurnTimer(40, turnEndCallback)
      if(@state.possiblePlayers.length == 0)
        @scoreAdder()


  checkChallengeDecision:(clientId) ->
    if !@challengeMode
      @throwError(0, {}, "Can't submit opinion, not currently challenge mode")
    if (clientId in @state.possiblePlayers) || (clientId in @state.impossiblePlayers)
      @throwError(0, {}, "Already stated your opinion")


  # Check if everyone has submitted their decisions for the decision making turn
  allDecisionsMade:() -> (@players.length == (@state.possiblePlayers.length + @state.impossiblePlayers.length))



  ###*
   * @param  {Integer} socketId      The nowjs socket of the player
   * @param  {Integer[]} dice An array of indices to the globalArray for the answer we need to check.
  ###
  submitSolution: (socketId, dice) ->
    if !@challengeMode then throw "Not in challenge mode"
    playerid = @getPlayerIdBySocket(socketId)
    if (playerid in @state.possiblePlayers)
      # If he hasn't already submitted a solution..
      if (@submittedSolutions[playerid]?) then throw @throwError(0, {}, "Player #{socketId} already submitted solution which is: #{@submittedSolutions[playerid]}")
      # Check if the solution submitted is valid

      diceValues = []
      numRequiredInAns = 0
      numUnallocatedInAns = 0
      numGlobalDice = @globalDice.length
      for i in [0 ... dice.length]
        for j in [i+1 ... dice.length]
          if (dice[i] < -2  || dice[i] >= numGlobalDice) then throw @throwError(0, {}, "Solution has out of bounds array index")
          if (dice[i] == dice[j] && i!=j  && dice[i] >= 0) then throw @throwError(0, {}, "Solution uses duplicate dice")

        if dice[i] == -1
          diceValues.push(DICEFACESYMBOLS.bracketL)
        else if dice[i] == -2
          diceValues.push(DICEFACESYMBOLS.bracketR)
        else
          diceValues.push(@globalDice[dice[i]])
        if(dice[i] in @state.forbidden) then throw @throwError(0, {}, "Solution uses dice from forbidden")
        if(dice[i] in @state.required) then numRequiredInAns++
        if(dice[i] in @state.unallocated) then numUnallocatedInAns++

      if(numRequiredInAns < @state.required.length) then @throwError(0, {}, "Solution doesn't use all dice from required")
      if(numUnallocatedInAns > 1 && @challengeModeNow) then throw @throwError(0, {}, "Solution doesn't use one dice from unallocated")

      # Everything ok-doky index wise. Now let's check it parses and gives the same value.
      e = new Evaluator
      p = new ExpressionParser
      # TODO separate out and wrap in try catch
      submissionValue = e.evaluate(p.parse(diceValues,false))
      # Ok it does. So add it to the submitted solutions list
      @rightAnswers[playerid] = (@goalValue == submissionValue)
      @submittedSolutions[playerid] = dice
      
    else
      playerid = @getPlayerIdBySocket(socketId)
      @throwError(0, {}, "Client not in 'possible' list")
    if(@allSolutionsSent()) then @scoreAdder()

  allSolutionsSent: () ->
    for i in @state.possiblePlayers
      if !@submittedSolutions[i]?
        return false
    return true

  # Return a copy of the submitted solutions
  getSubmittedSolutions: () -> @submittedSolutions[..]
  getAnswerExists: () -> @answerExists
  getRoundChallengePoints: () -> @challengePoints[..]
  getRoundDecisionPoints: () -> @decisionPoints[..]
  getRoundSolutionPoints: () -> @solutionPoints[..]




  scoreAdder: ->
    # See if we definitely know it's solvable. See if somebody got the goal.
    
    for playerid in [0...@players.length]
      if @rightAnswers[playerid] then @answerExists = true
    # If at least one person solved it, then we knows it possible. Give points to everyone who tried
    # and give even more points to everyone who got it right. Give the most to the challenger.
    # Otherwise, we assume it wasn't possible and give points to the people who said never.
    if @answerExists
      for playerid in [0...@players.length]
        # Points for making that right decision
        if playerid in @state.possiblePlayers
          @decisionPoints[playerid] = 2
        # Points for getting the correct solution
        if @rightAnswers[playerid]
          @solutionPoints[playerid] = 2
        # Points for being the challenger
        if @challenger == playerid && playerid in @state.possiblePlayers
          @challengePoints[playerid] = 2
    else
      for playerid in [0...@players.length]
        if playerid in @state.impossiblePlayers
          @decisionPoints[playerid] = 2
        if @challenger == playerid && playerid in @state.impossiblePlayers
          @challengePoints[playerid] = 2

    # Now add the scores to the player
    for i in [0...@players.length]
      if(@decisionPoints[i]?) then @state.playerScores[i] += @decisionPoints[i]
      if(@solutionPoints[i]?) then @state.playerScores[i] += @solutionPoints[i]
      if(@challengePoints[i]?) then @state.playerScores[i] += @challengePoints[i]
  
  readyForNextRound: (clientid) ->
    index = @getPlayerIdBySocket(clientid)
    if(index not in @state.readyForNextRound) then @state.readyForNextRound.push(index)

  allNextRoundReady: () -> @state.readyForNextRound.length == @players.length

  nextRound: ->
    @goalTree = undefined
    @goalArray = []
    @goalValue = undefined
    @goalSetter = undefined
    @started = false
    @globalDice = []
    @challengeMode = false
    @challengeModeNow = false
    @challenger = undefined
    @submittedSolutions = []
    @rightAnswers = []
    @state.unallocated = []
    @state.playerScores = [] #don't we wan't to keep track of scores as games progress?
    @state.required = []
    @state.optional = []
    @state.forbidden = []
    @state.currentPlayer = 0
    @state.possiblePlayers = []
    @state.impossiblePlayers = []
    @state.turnNumber = 0
    @answerExists = false
    @challengePoints = []
    @decisionPoints = []
    @solutionPoints = []
    @state.readyForNextRound = []
    @goalStart()
    @allocate()

  restartGame: ->
    @constructor(@gameNumber, @name, @gameSize)
    ###
    @nextRound()
    @state.playerScores = []
    @players = []
    @started = false
    @playerSocketIds = []
    ###


  module.exports.Game = Game
