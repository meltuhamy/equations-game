{DiceFace} = require './DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols

{ErrorManager}  = require './ErrorManager.js'
ERRORCODES = ErrorManager.codes

{ExpressionParser, Node} = require './Parser.js'
{Player} = require './Player.js'
{PlayerManager} = require './PlayerManager.js'
{Evaluator} = require './Evaluator.js'
{Settings} = require './Settings.js'


class Game

  goalTree: undefined
  goalArray: []
  goalValue: undefined

  # {String} The name of the game as it appears on the lobby etc.
  name: ''

  # {String} The string id for the nowjs group/room used for players in this game
  nowJsGroupName: ''

  # {Number} The index to the games array
  gameNumber: 0

  # {Boolean} True when the game has started (is full)
  started: false

  # {PlayerManager} The player manager that manages players
  playerManager = undefined

  # {Number} The dice that will be used throughout the game. An array of diceface magic numbers.
  globalDice: []

  # {Boolean} Has the turn taking halted for a challenge?
  challengeMode: false

  # {Boolean} Differentiates between now and never challenges
  challengeModeNow: false

  # {Boolean} Has the game ended?
  endOfGame: false

  # {Object} A JSON object that reperesents the game state.
  state: undefined



  
  constructor: (@gameNumber, @name, gameSize, numRounds, throwErrors = true) ->
    # Initalise all variables so that they're object (not prototype) specfific
    
    @playerManager = new PlayerManager()
    
    @throwErrors = throwErrors
    @goalTree = undefined
    @goalArray = []
    @goalValue = undefined
    @name= ''
    @nowJsGroupName= ''

    @started = false
    @challengeMode = false

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
      # {Number} The current round
      currentRound: 1
      # {Number} The total number of rounds
      numRounds: numRounds
    


    @numRounds = numRounds
    @gameNumber = gameNumber
    @name = name
    @gameSize = gameSize
    if gameSize?
      if gameSize > 2 then @playerManager.playerLimit = gameSize
    @nowJsGroupName = "game#{gameNumber}"
    @allocate()


  goalHasBeenSet: () ->
    @goalTree? #returns false if goalTree undefined, true otherwise


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
    if Settings.DEBUG
      # TODO move this ugly thing to a settings file
      @globalDice = Settings.DEBUGDICE
    else
      ops = 0
      @globalDice = []  #clear the array first
      #console.log(@globalDice) 
      for x in [1..24]  #24 dice rolls
        rand = Math.random()  #get a random number
        if rand < 2/3  #first we decide if the roll yields an operator or a digit
          rand = Math.floor(Math.random() * 10)  #2/3 of the time we get a digit, decided by a new random number
        else  #1/3 of the time we get an operator, again we generate a new random number to decide which operator to use
          rand = Math.floor(Math.random() * - DiceFace.numOps)
          ops++ #we keep track of the number of operators generated so that later we can check if there are enough
        @globalDice.push(rand)  #here we add the die to the global dice array
      if (ops < 2) || (ops > 21)  #if there are too few or too many operators, we must roll again
        #@globalDice = [] #clear the array first
        @allocate()  #do the allocation again


  ###*
   * [setGoal description]
   * the function that calls this (everyone.now.receiveGoal() in server.coffee) handles any thrown exceptions
   * @param {Integer} dice [description]
  ###

  setGoal: (dice, turnEndCallback) ->  
    if @goalHasBeenSet() #if goal already set
      ErrorManager.throw(ErrorManager.codes.goalAlreadySet, {}, "Goal already set")
    
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
    if (dices > 6)
      ErrorManager.throw(ERRORCODES.goalTooLarge, {}, "Goal uses more than six dice")

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
        if (dice[i] < -2  || dice[i] >= numGlobalDice) then ErrorManager.throw(ErrorManager.codes.outOfBoundsDice, {}, "Goal has out of bounds array index")
        if (dice[i] == dice[j] && i!=j  && dice[i] >= 0) then ErrorManager.throw(ErrorManager.codes.duplicateDice, {}, "Goal uses duplicates dice")
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
  addClient: (clientid, playerName) ->
    if @playerManager.full() || @started
      ErrorManager.throw(ErrorManager.codes.gameFull, {}, "Game full or already started")
    else
      newPlayerIndex = @playerManager.add(clientid, playerName)
      @state.playerScores[newPlayerIndex] = 0
      return newPlayerIndex

  ###*
   * Removes the client and player with clientid
   * @param  {String} clientid The client id of the player to be removed
   * @return {Number}          The player id of the player that was removed.
  ###
  removeClient: (clientid) ->
    if @playerManager.players.length == 2
      @restartGame()
    else #now we need to update players and playersocketIds
      index = @playerManager.remove(clientid)

      #now we update possiblePlayers, impossiblePlayers and readyForNextRound arrays in state
      @state.playerScores.splice(index, 1)
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
        @state.currentPlayer = @playerManager.players.length
      return index



  isFull: () -> @playerManager.players.length == @playerManager.playerLimit
  getNumPlayers: () -> return @playerManager.players.length

  
  ###*
   * Get the index of the player who moves the first dice from unallocated
   * @return {[Integer} An index to the players array
  ###
  getFirstTurnPlayerId: () -> 
    if !@playerManager.goalSetter? then @getGoalSetterPlayerId()
    return @playerManager.goalSetter+1%@playerManager.players.length
  # If we want to get his socket id instead of the player array index
  getFirstTurnPlayerSocketId: () -> @playerManager.getPlayerSocketById(@getFirstTurnPlayerId())

  ###*
   * Return the index of the player who will set the goal
   * @return {[Integer} An index to the players array
  ###
  getGoalSetterPlayerId: () ->
    if !@playerManager.goalSetter?
      @setGoalSetterPlayerId()
    @playerManager.goalSetter

  ###*
   * Gets a random player id (index).
   * @param  {Number[]} exceptions If this is provided, the "random" player number will not include anything in this array.
   * @return {Number}            A player id (index)
  ###
  randomPlayerId: (exceptions) ->
    e = [].concat(exceptions)
    newNumber = Math.floor(Math.random() * @playerManager.players.length)
    newNumber = Math.floor(Math.random() * @playerManager.players.length) while newNumber in e
    return newNumber

  ###*
   * Sets the goal setter to forceId. If no parameter given, chooses random goalSetter.
   * @param {Number} forceId If provided, will give the goal setter this id, otherwise a random.
  ###
  setGoalSetterPlayerId: (forceId) ->
    if(!forceId?)
      #set a random goalSetter
      if Settings.DEBUG
        @playerManager.goalSetter = 0
      else
        exceptions = if @playerManager.goalSetter? then @playerManager.goalSetter else []
        @playerManager.goalSetter = @randomPlayerId(exceptions)
    else
      @playerManager.goalSetter = forceId



  ###*
   * See if this player is allowed to make this move.
   * @param  {[type]} socketId The nowjs socket id of the player.
   * @return {[type]}          Return True if it is this player's turn to move 
  ###
  authenticateMove: (socketId) -> #returns a boolean 
    (socketId == @playerManager.playerSocketIds[@state.currentPlayer])

  validateChallenge: (socketId) ->
    (socketId != @playerManager.playerSocketIds[((@state.currentPlayer-1)+@playerManager.players.length)%@playerManager.players.length])


  goalStart: (turnEndCallback) ->
    @started = true
    # TODO: add callback for timer
    @state.turnNumber = 0
    @resetTurnTimer(Settings.goalSeconds, turnEndCallback)


  start: (turnEndCallback) ->
    @state.currentPlayer = (@playerManager.goalSetter+1)%@playerManager.players.length
    @state.turnNumber = 1
    @resetTurnTimer(Settings.turnSeconds, turnEndCallback)
    

  nextTurn: (turnEndCallback) ->
    if @started
      @state.currentPlayer = (@state.currentPlayer+1)%@playerManager.players.length
      @state.turnNumber += 1
      @resetTurnTimer(Settings.turnSeconds, turnEndCallback)
    else
      clearInterval(@turnTimer)
    
  

  ###*
   * When the turn has changed reset the timer back to the start.  
   * @param  {Integer} turnSeconds       The number of seconds until the each of the turn.
   * @param  {Function} endOfTurnTimeFunc This function is called when the time is up.
  ###
  resetTurnTimer: (turnSeconds, turnEndCallback) ->
    if @started
      @originalTurnSeconds = turnSeconds
      @state.turnStartTime = Date.now()
      @state.turnDuration = turnSeconds
      @state.turnEndTime = @state.turnStartTime + @originalTurnSeconds*1000
      @turnEndCallback = turnEndCallback
      clearInterval(@turnTimer)
      # Has the player completed his turn BEFORE end of time?
      thisReference = this
      @turnTimer = setInterval ->
        thisReference.handleTimeOut(thisReference.turnEndCallback)
        if(thisReference.turnEndCallback?) then thisReference.turnEndCallback() else console.log "TURN OVER"
      , turnSeconds*1000
    else
      clearInterval(@turnTimer)

  pauseTurnTimer: () ->
    if !@pausedTime?
      @pausedTime = Date.now()
      clearInterval(@turnTimer)
    else
      console.log "Game already paused."

  resumeTurnTimer: () ->
    @state.turnStartTime = Date.now()
    resumeDuration = @state.turnEndTime -  @pausedTime
    if resumeDuration < 0 then resumeDuration = 0
    @state.turnDuration = resumeDuration / 1000.0
    @resetTurnTimer(@state.turnDuration, @turnEndCallback)
    @pausedTime = undefined




  handleTimeOut: (turnEndCallback) ->
    if @started
      if @challengeMode
        # Move players into the option that makes them submit a solution
        if(!@allDecisionsMade())
          console.log "NOT EVERYONE MADE DECISION"
          for p in @playerManager.players
            index = p.index
            if((index not in @state.possiblePlayers) and (index not in @state.impossiblePlayers))
              @submitPossible(@playerManager.getPlayerSocketById(index))
      else if @state.turnNumber == 0
        #Time ran out on goal setting screen. Choose new player to set goal
        @setGoalSetterPlayerId()
      else
        # Move onto the next allocation turn
        @nextTurn(turnEndCallback)


    else
      clearInterval(@turnTimer)

  ## Penalise a player for taking too long (too often).
  ## returns true if he should be removed from game for bad behavior.
  penalisePlayer: () ->
    missplayer = @state.currentPlayer
    # Basic system for Penalising player for taking too
    @playerManager.players[missplayer].turnMisses += 1
    @playerManager.players[missplayer].consecutiveTurnMisses += 1

    # Three Rules (only one rule at a time) for Penalising players:
    # 1. Two consecutive missed turns. He loses 2 points.
    # 2. Three consecutive missed turns. He gets kicked out.
    # 3. If total misses >= total moves played > 3. He gets kicked out.
    if(@playerManager.players[missplayer].consecutiveTurnMisses == 2)
      # First Rule
      if(@state.playerScores[missplayer] > 2)
        @state.playerScores[missplayer] -= 2
    else if(@playerManager.players[missplayer].consecutiveTurnMisses >= 3)
      # Second Rule
      @removeClient(@playerManager.getPlayerSocketById(missplayer))
      console.log "BAD PLAYER REMOVED"
      return true
    else if(@playerManager.players[missplayer].turnMisses >= @playerManager.players[missplayer].movesPlayed)
      # Third rule
      if(@playerManager.players[missplayer].movesPlayed > 3)
        @removeClient(@playerManager.getPlayerSocketById(missplayer))
        console.log "BAD PLAYER REMOVED"
        return true
    return true


  checkValidAllocationMove: (index, clientId) ->
    if @challengeMode
      ErrorManager.throw(ErrorManager.codes.moveDuringChallenge, {}, "Can't move during challenge mode")
    if !@goalHasBeenSet()
      ErrorManager.throw(ErrorManager.codes.moveWithoutGoal, {}, "Can't move yet, goal has not been set")
    if !@authenticateMove(clientId)
      ErrorManager.throw(ErrorManager.codes.notYourTurn, {}, "Not your turn")
    else if index < 0 || index >= @state.unallocated.length
      ErrorManager.throw(ErrorManager.codes.outOfBoundsDice, {}, "Index for move out of bounds")
    else true

  moveToRequired: (index, clientId, turnEndCallback) ->
    if(@checkValidAllocationMove(index, clientId))
      @state.required.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @playerManager.players[@playerManager.getPlayerIdBySocket(clientId)].consecutiveTurnMisses = 0
      @nextTurn(turnEndCallback)

  moveToOptional: (index, clientId, turnEndCallback) ->
   if(@checkValidAllocationMove(index, clientId))
      @state.optional.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @playerManager.players[@playerManager.getPlayerIdBySocket(clientId)].consecutiveTurnMisses = 0
      @nextTurn(turnEndCallback)

  moveToForbidden: (index, clientId, turnEndCallback) ->
    if(@checkValidAllocationMove(index, clientId))
      @state.forbidden.push(@state.unallocated[index])
      @state.unallocated.splice(index, 1)
      @playerManager.players[@playerManager.getPlayerIdBySocket(clientId)].consecutiveTurnMisses = 0
      @nextTurn(turnEndCallback)

  ###*
   * Attempt to g into the decide stage of a now challenge.
   * @param  {Integer} clientId The nowjs unqiue id for client
  ###
  nowChallenge: (clientId, turnEndCallback) ->
    @challengeMode = true
    @challengeModeNow = true
    @playerManager.challenger = @playerManager.getPlayerIdBySocket(clientId)
    @state.possiblePlayers.push(@playerManager.getPlayerIdBySocket(clientId))
    @resetTurnTimer(Settings.challengeDecisionTurnSeconds, turnEndCallback)


  neverChallenge: (clientId, turnEndCallback) ->
    @challengeMode = true
    @challengeModeNow = false
    @playerManager.challenger = @playerManager.getPlayerIdBySocket(clientId)
    @state.impossiblePlayers.push(@playerManager.getPlayerIdBySocket(clientId))
    @resetTurnTimer(Settings.challengeDecisionTurnSeconds, turnEndCallback)

  submitPossible: (clientId, turnEndCallback) ->
    @checkChallengeDecision()
    @state.possiblePlayers.push(@playerManager.getPlayerIdBySocket(clientId))
    if(@allDecisionsMade())
      # Give 40 seconds for the solutions turn
      @resetTurnTimer(Settings.submitTurnSeconds, turnEndCallback)

  submitImpossible: (clientId, turnEndCallback) ->
    @checkChallengeDecision()
    @state.impossiblePlayers.push(@playerManager.getPlayerIdBySocket(clientId))
    if(@allDecisionsMade())
      # Give 40 seconds for the solutions turn
      @resetTurnTimer(Settings.submitTurnSeconds, turnEndCallback)
      if(@state.possiblePlayers.length == 0)
        @scoreAdder()


  checkChallengeDecision:(clientId) ->
    if !@challengeMode
      ErrorManager.throw(ErrorManager.codes.submitNotChallengeMode, {}, "Can't submit opinion, not currently challenge mode")
    if (clientId in @state.possiblePlayers) || (clientId in @state.impossiblePlayers)
      ErrorManager.throw(ErrorManager.codes.alreadyGaveOpinion, {}, "Already stated your opinion")


  # Check if everyone has submitted their decisions for the decision making turn
  allDecisionsMade:() -> (@playerManager.players.length == (@state.possiblePlayers.length + @state.impossiblePlayers.length))



  ###*
   * @param  {Integer} socketId      The nowjs socket of the player
   * @param  {Integer[]} dice An array of indices to the globalArray for the answer we need to check.
  ###
  submitSolution: (socketId, dice) ->
    if !@challengeMode then ErrorManager.throw(ErrorManager.codes.submitNotChallengeMode, {}, "Can't submit opinion, not currently challenge mode")
    playerid = @playerManager.getPlayerIdBySocket(socketId)
    if (playerid in @state.possiblePlayers)
      # If he hasn't already submitted a solution..
      if (@playerManager.submittedSolutions[playerid]?) then ErrorManager.throw(ErrorManager.codes.alreadySubmittedSolution, {solution: @playerManager.submittedSolutions[playerid]}, "You already submitted your solution")
      # Check if the solution submitted is valid

      diceValues = []
      numRequiredInAns = 0
      numUnallocatedInAns = 0
      numGlobalDice = @globalDice.length
      for i in [0 ... dice.length]
        for j in [i+1 ... dice.length]
          if (dice[i] < -2  || dice[i] >= numGlobalDice) then ErrorManager.throw(ErrorManager.codes.outOfBoundsDice, {}, "Solution has out of bounds array index")
          if (dice[i] == dice[j] && i!=j  && dice[i] >= 0) then ErrorManager.throw(ErrorManager.codes.duplicateDice, {}, "Solution uses duplicate dice")

        if dice[i] == -1
          diceValues.push(DICEFACESYMBOLS.bracketL)
        else if dice[i] == -2
          diceValues.push(DICEFACESYMBOLS.bracketR)
        else
          diceValues.push(@globalDice[dice[i]])
        if(dice[i] in @state.forbidden) then ErrorManager.throw(ErrorManager.codes.usesForbidden, {}, "Solution uses dice from forbidden")
        if(dice[i] in @state.required) then numRequiredInAns++
        if(dice[i] in @state.unallocated) then numUnallocatedInAns++

      if(numRequiredInAns < @state.required.length) then ErrorManager.throw(ErrorManager.codes.doesntUseAllRequired, {}, "Solution doesn't use all of the required dice.")
      if(numUnallocatedInAns > 1 && @challengeModeNow) then ErrorManager.throw(ErrorManager.codes.doesntUseOneUnallocated, {}, "Solution doesnt use one grey dice")

      # Everything ok-doky index wise. Now let's check it parses and gives the same value.
      e = new Evaluator
      p = new ExpressionParser #do we need to pass in anything for error codes etc?
      # TODO separate out and wrap in try catch
      submissionValue = e.evaluate(p.parse(diceValues, false)) #pass in false because not a goal
      # Ok it does. So add it to the submitted solutions list
      @playerManager.rightAnswers[playerid] = (@goalValue == submissionValue)
      @playerManager.submittedSolutions[playerid] = dice
      
    else
      playerid = @playerManager.getPlayerIdBySocket(socketId)
      ErrorManager.throw(ErrorManager.codes.possibleSubmitSolution, {}, "Client not in 'possible' list")
    if(@allSolutionsSent()) then @scoreAdder()

  allSolutionsSent: () ->
    for i in @state.possiblePlayers
      if !@playerManager.submittedSolutions[i]?
        return false
    return true

  # Return a copy of the submitted solutions
  getSubmittedSolutions: () -> @playerManager.submittedSolutions[..]
  getAnswerExists: () -> @answerExists
  getRoundChallengePoints: () -> @challengePoints[..]
  getRoundDecisionPoints: () -> @decisionPoints[..]
  getRoundSolutionPoints: () -> @solutionPoints[..]




  scoreAdder: ->
    # See if we definitely know it's solvable. See if somebody got the goal.
    
    for playerid in [0...@playerManager.players.length]
      if @playerManager.rightAnswers[playerid] then @answerExists = true
    # If at least one person solved it, then we knows it possible. Give points to everyone who tried
    # and give even more points to everyone who got it right. Give the most to the challenger.
    # Otherwise, we assume it wasn't possible and give points to the people who said never.
    if @answerExists
      for playerid in [0...@playerManager.players.length]
        # Points for making that right decision
        if playerid in @state.possiblePlayers
          @decisionPoints[playerid] = 2
        # Points for getting the correct solution
        if @playerManager.rightAnswers[playerid]
          @solutionPoints[playerid] = 2
        # Points for being the challenger
        if @playerManager.challenger == playerid && playerid in @state.possiblePlayers
          @challengePoints[playerid] = 2
    else
      for playerid in [0...@playerManager.players.length]
        if playerid in @state.impossiblePlayers
          @decisionPoints[playerid] = 2
        if @playerManager.challenger == playerid && playerid in @state.impossiblePlayers
          @challengePoints[playerid] = 2

    # Now add the scores to the player
    for i in [0...@playerManager.players.length]
      if(@decisionPoints[i]?) then @state.playerScores[i] += @decisionPoints[i]
      if(@solutionPoints[i]?) then @state.playerScores[i] += @solutionPoints[i]
      if(@challengePoints[i]?) then @state.playerScores[i] += @challengePoints[i]
  
  readyForNextRound: (clientid) ->
    index = @playerManager.getPlayerIdBySocket(clientid)
    if(index not in @state.readyForNextRound) then @state.readyForNextRound.push(index)

  allNextRoundReady: () -> @state.readyForNextRound.length == @playerManager.players.length

  nextRound: ->
    @goalTree = undefined
    @goalArray = []
    @goalValue = undefined
    @playerManager.goalSetter = undefined
    @started = false
    @globalDice = []
    @challengeMode = false
    @challengeModeNow = false
    @playerManager.challenger = undefined
    @playerManager.submittedSolutions = []
    @playerManager.rightAnswers = []
    @state.unallocated = []
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

    # check if it's the last round and update the current round
    if @state.currentRound > @state.numRounds then @endGame() else @state.currentRound++


  endGame: ->
    @endOfGame = true

  isGameOver: -> @endOfGame or @state.currentRound > @state.numRounds

  restartGame: ->
    @nextRound()
    @constructor(@gameNumber, @name, @gameSize, @state.numRounds, @endOfGameCallback)


  module.exports.Game = Game
