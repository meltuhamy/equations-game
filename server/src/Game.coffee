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



  
  constructor: (@gameNumber, @name, gameSize, numRounds) ->
    # Initalise all variables so that they're object (not prototype) specfific
    
    @playerManager = new PlayerManager()
    
    @goalTree = undefined
    @goalArray = []
    @goalValue = undefined
    @name= ''
    @nowJsGroupName= ''

    @started = false
    @challengeMode = false

    @answerExists = false

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

  ###*
   * This checks whether a goal is a subset of the resources dice and can be parsed.
   * @param  {Integer[]} dice An array of indices to the resource
   * @return {Boolean} True when the goal is valid.
  ###
  checkGoal: (dice) ->
    # First check there are not too many dice in the goal
    dices = 0
    for i in [0..dice.length]
      if (dice[i] >= 0)
        dices++
      i++
    if (dices > 6) # detects if more than 6 dice are used on the goal
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
        # detects if the dice used is out of bounds/not allowed
        if (dice[i] < -2  || dice[i] >= numGlobalDice) then ErrorManager.throw(ErrorManager.codes.outOfBoundsDice, {}, "Goal has out of bounds array index")
        # detects if the same dice has been used twice
        if (dice[i] == dice[j] && i!=j  && dice[i] >= 0) then ErrorManager.throw(ErrorManager.codes.duplicateDice, {}, "Goal uses duplicates dice")
      if dice[i] == -1  # detects and pushes left brackets
        diceValues.push(DICEFACESYMBOLS.bracketL)
      else if dice[i] == -2 # detects and pushes right brackets
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

  # returns true if the room is full, false therwise
  isFull: () -> @playerManager.full()
  # returns the number of players currently in the room
  getNumPlayers: () -> @playerManager.numPlayers()

  
  ###*
   * [goalStart description]
   * @param  {[type]} turnEndCallback [description]
   * @return {[type]}                 [description]
  ###
  goalStart: (turnEndCallback) ->
    @started = true
    @state.turnNumber = 0
    @resetTurnTimer(Settings.goalSeconds, turnEndCallback)

  ###*
   * For allocation turns, start with the player after goal setter.
   * @param  {Function} turnEndCallback What to do if time ends on his turn.
  ###
  start: (turnEndCallback) ->
    @state.currentPlayer = (@playerManager.goalSetter+1)%@getNumPlayers()
    @state.turnNumber = 1
    @resetTurnTimer(Settings.turnSeconds, turnEndCallback)
    
  ###*
   * For allocation turns, move to the next player.
   * @param  {Function} turnEndCallback What to do if time ends on his turn.
  ###
  nextTurn: (turnEndCallback) ->
    # Only move onto the next player if the goal has been set
    if @started
      @state.currentPlayer = (@state.currentPlayer+1)%@getNumPlayers()
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

  # For debug purposes - pause the timer for the current turn
  pauseTurnTimer: () ->
    # Make idempotent - only pause if game isn't already paused
    if !@pausedTime?
      @pausedTime = Date.now()
      clearInterval(@turnTimer)
    else
      console.log "Game already paused."

  # For debug purposes - resume a paused timer
  resumeTurnTimer: () ->
    @state.turnStartTime = Date.now()
    resumeDuration = @state.turnEndTime -  @pausedTime
    if resumeDuration < 0 then resumeDuration = 0
    @state.turnDuration = resumeDuration / 1000.0
    @resetTurnTimer(@state.turnDuration, @turnEndCallback)
    @pausedTime = undefined



  ###*
   * This is called whenever the timer runs on on a turn. This looks at the current point
   * of the game - does any code that was no in previous turn's turnEndCallback 
   * @param  {[type]} turnEndCallback (Optional) A new turnEndCallback for next turn
  ###
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
        @playerManager.setGoalSetterPlayerId()
      else
        # Move onto the next allocation turn
        @nextTurn(turnEndCallback)


    else
      clearInterval(@turnTimer)

  ## Penalise a player for taking too long (too often).
  ## returns true if he should be removed from game for bad behavior.
  penalisePlayer: () ->
    missplayerId = @state.currentPlayer
    missPlayer = @playerManager.getPlayerById(missplayerId)
    # Basic system for Penalising player for taking too
    missPlayer.turnMisses += 1
    missPlayer.consecutiveTurnMisses += 1

    # Three Rules (only one rule at a time) for Penalising players:
    # 1. Two consecutive missed turns. He loses 2 points.
    # 2. Three consecutive missed turns. He gets kicked out.
    # 3. If total misses >= total moves played > 3. He gets kicked out.
    if(missplayer.consecutiveTurnMisses == 2)
      # First Rule
      if(@state.playerScores[missplayerId] > 2)
        @state.playerScores[missplayerId] -= 2
    else if(missplayer.consecutiveTurnMisses >= 3)
      # Second Rule
      @removeClient(@playerManager.getPlayerSocketById(missplayer))
      console.log "BAD PLAYER REMOVED"
      return true
    else if(missplayer.turnMisses >= @missplayer.movesPlayed)
      # Third rule
      if(missplayer.movesPlayed > 3)
        @removeClient(@playerManager.getPlayerSocketById(missplayer))
        console.log "BAD PLAYER REMOVED"
        return true
    return true

  # Used on each allocation turn to check player if valid and check allocation move is valid.
  checkValidAllocationMove: (index, clientId) ->
    if @challengeMode # prevents moves from taking place during challenge mode
      ErrorManager.throw(ErrorManager.codes.moveDuringChallenge, {}, "Can't move during challenge mode")
    if !@goalHasBeenSet() # prevents moves from taking place before setting the goal
      ErrorManager.throw(ErrorManager.codes.moveWithoutGoal, {}, "Can't move yet, goal has not been set")
    if !@playerManager.authenticateMove(clientId, @state.currentPlayer) # prevents moves from taking place it's not the player's turn
      ErrorManager.throw(ErrorManager.codes.notYourTurn, {}, "Not your turn")
    else if index < 0 || index >= @state.unallocated.length # prevents moves from taking place if the dice is out of baounds
      ErrorManager.throw(ErrorManager.codes.outOfBoundsDice, {}, "Index for move out of bounds")
    else true

  # Moves the dice to the required array or 'mat'
  moveToRequired: (index, clientId, turnEndCallback) ->
    if(@checkValidAllocationMove(index, clientId)) # checks move is valid
      @state.required.push(@state.unallocated[index]) # pushes the dice at index to required
      @state.unallocated.splice(index, 1) #  removes the dice from unallocated at index
      @playerManager.players[@playerManager.getPlayerIdBySocket(clientId)].consecutiveTurnMisses = 0 # resets missed turns to 0
      @nextTurn(turnEndCallback) # moves to next turn

  # Moves the dice to the optional array or 'mat'
  moveToOptional: (index, clientId, turnEndCallback) ->
   if(@checkValidAllocationMove(index, clientId)) # checks move is valid
      @state.optional.push(@state.unallocated[index]) # pushes the dice at index to optional
      @state.unallocated.splice(index, 1)  # removes the dice from unallocated at index
      @playerManager.players[@playerManager.getPlayerIdBySocket(clientId)].consecutiveTurnMisses = 0 # resets missed turns to 0
      @nextTurn(turnEndCallback) # moves to next turn

  # Moves the dice to the forbidden array or 'mat'
  moveToForbidden: (index, clientId, turnEndCallback) ->
    if(@checkValidAllocationMove(index, clientId)) # checks move is valid
      @state.forbidden.push(@state.unallocated[index]) # pushes the dice at index to forbidden
      @state.unallocated.splice(index, 1) # removes the dice from unallocated at index
      @playerManager.players[@playerManager.getPlayerIdBySocket(clientId)].consecutiveTurnMisses = 0 # resets missed turns to 0
      @nextTurn(turnEndCallback) # moves to next turn


  ###*
   * Attempt to get into the decide stage of a now challenge.
   * @param  {Integer} clientId The nowjs unique id for client
  ###
  nowChallenge: (clientId, turnEndCallback) ->
    @challengeMode = true
    @challengeModeNow = true
    challengerId = @playerManager.setChallengerBySocket(clientId)
    @state.possiblePlayers.push(challengerId)
    @resetTurnTimer(Settings.challengeDecisionTurnSeconds, turnEndCallback)

  ###*
   * Attempt to get into the decide stage of a never challenge.
   * @param  {Integer} clientId The nowjs unique id for client
  ###
  neverChallenge: (clientId, turnEndCallback) ->
    @challengeMode = true
    @challengeModeNow = false
    challengerId = @playerManager.setChallengerBySocket(clientId)
    @state.impossiblePlayers.push(challengerId)
    @resetTurnTimer(Settings.challengeDecisionTurnSeconds, turnEndCallback)

  ###*
   * A player has submitted that he thinks a challenge is possible.
   * @param  {Integer} clientId        The now.js socketid given to player
   * @param  {Function} turnEndCallback What to do if the timer ends on the solutions turn.
  ###
  submitPossible: (clientId, turnEndCallback) ->
    @checkChallengeDecision()
    agreedId = @playerManager.getPlayerIdBySocket(clientId) #The player id of the player who agreed
    @state.possiblePlayers.push(agreedId)
    if(@allDecisionsMade())
      # Give 40 seconds for the solutions turn
      @resetTurnTimer(Settings.submitTurnSeconds, turnEndCallback)

  ###*
   * A player has submitted that he thinks a challenge is not possible.
   * @param  {Integer} clientId        The now.js socketid given to player
   * @param  {Function} turnEndCallback What to do if the timer ends on the solutions turn.
  ###
  submitImpossible: (clientId, turnEndCallback) ->
    @checkChallengeDecision()
    disagreedId = @playerManager.getPlayerIdBySocket(clientId) #The player id of the player who disagreed
    @state.impossiblePlayers.push(disagreedId)
    # Once we have accepted his decision, check whether all are made.
    # If so, and everyone thinks it's impossible then it's the end of round. Add up scores.
    if(@allDecisionsMade())
      @resetTurnTimer(Settings.submitTurnSeconds, turnEndCallback)
      if(@state.possiblePlayers.length == 0)
        @scoreAdder()

  ###*
   * Check whether a possible/impossible decision make sense.
   * Prevent people making duplicate decisions or decisions at the wrong time.
   * @param  {Integer} clientId The now.js socketid given to player
  ###
  checkChallengeDecision:(clientId) ->
    if !@challengeMode
      ErrorManager.throw(ErrorManager.codes.submitNotChallengeMode, {}, "Can't submit opinion, not currently challenge mode")
    if (clientId in @state.possiblePlayers) || (clientId in @state.impossiblePlayers)
      ErrorManager.throw(ErrorManager.codes.alreadyGaveOpinion, {}, "Already stated your opinion")


  ###*
   * Check if everyone has submitted their decisions for the decision making turn
   * @return {Boolean} True if everyone submitted their decisions
  ###
  allDecisionsMade: -> @getNumPlayers() is (@state.possiblePlayers.length+@state.impossiblePlayers.length)


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
          # If he uses globalDice indices that don't make sense, give error.
          # If he uses globalDice indices twice, then he's used two identical dice twice. He's cheated. Give error.
          if (dice[i] < -2  || dice[i] >= numGlobalDice) then ErrorManager.throw(ErrorManager.codes.outOfBoundsDice, {}, "Solution has out of bounds array index")
          if (dice[i] == dice[j] && i!=j  && dice[i] >= 0) then ErrorManager.throw(ErrorManager.codes.duplicateDice, {}, "Solution uses duplicate dice")
        # -1 and -2 are pseudo-indicies reserved for left/right brackets. handle this case.
        # otherwise add the corresponding globalDice into our temporary solutions array we are building
        if dice[i] == -1
          diceValues.push(DICEFACESYMBOLS.bracketL)
        else if dice[i] == -2
          diceValues.push(DICEFACESYMBOLS.bracketR)
        else
          diceValues.push(@globalDice[dice[i]])
        # Now check that he has used the allocations correctly.
        # He can't use any forbidden dice, must use all the required, and only one unallocated.
        if(dice[i] in @state.forbidden) then ErrorManager.throw(ErrorManager.codes.usesForbidden, {}, "Solution uses dice from forbidden")
        if(dice[i] in @state.required) then numRequiredInAns++
        if(dice[i] in @state.unallocated) then numUnallocatedInAns++
      # Checks for using all the required and only one unallocated. 
      if(numRequiredInAns < @state.required.length) then ErrorManager.throw(ErrorManager.codes.doesntUseAllRequired, {}, "Solution doesn't use all of the required dice.")
      if(numUnallocatedInAns > 1 && @challengeModeNow) then ErrorManager.throw(ErrorManager.codes.doesntUseOneUnallocated, {}, "Solution doesnt use one grey dice")

      # Everything ok-doky index wise. Now let's check it parses and gives the same value.
      e = new Evaluator
      p = new ExpressionParser #do we need to pass in anything for error codes etc?
      # TODO separate out and wrap in try catch
      submissionValue = e.evaluate(p.parse(diceValues, false)) #pass in false because not a goal
      # Ok it does. So add it to the submitted solutions list
      isCorrect = @goalValue is submissionValue
      @playerManager.submitSolution(playerid, dice, isCorrect)
      
    else
      playerid = @playerManager.getPlayerIdBySocket(socketId)
      ErrorManager.throw(ErrorManager.codes.possibleSubmitSolution, {}, "Client not in 'possible' list")
    # If everyone has submitted their solutions, it's the end of round. Add up the scores for the round.
    if(@allSolutionsSent()) then @scoreAdder()

  # returns true if all players that believe a solution is possible have sent their solution
  allSolutionsSent: () ->
    for i in @state.possiblePlayers
      if !@playerManager.isPlayerSubmittedSolution(i)
        return false
    return true

  # Return a copy of the submitted solutions
  getSubmittedSolutions: () -> @playerManager.submittedSolutions[..]
  # Has at least one person make a solution that solves the goal?
  getAnswerExists: () -> @answerExists
  # Return an array that gives the points for actually making the challenge.
  getRoundChallengePoints: () -> @playerManager.challengePoints[..]
  # Return an array that gives the points for whether they decided with challenge.
  getRoundDecisionPoints: () -> @playerManager.decisionPoints[..]
  # Return an array that gives the points for whether solutions submitted are correct
  getRoundSolutionPoints: () -> @playerManager.solutionPoints[..]



  ###*
   * Once every one has submitted their solutions. It's the end of the round. Add up points.
  ###
  scoreAdder: ->
    # See if we definitely know it's solvable. See if somebody got the goal.
    numPlayers = @getNumPlayers()
    for playerid in [0...numPlayers]
      if @playerManager.isRightAnswer(playerid) then @answerExists = true
      break # We now know an answer exists.

    # If at least one person solved it, then we knows it possible. Give points to everyone who tried
    # and give even more points to everyone who got it right. Give the most to the challenger.
    # Otherwise, we assume it wasn't possible and give points to the people who said never.
    if @answerExists
      for playerid in [0...numPlayers]
        # Points for making that right decision
        if playerid in @state.possiblePlayers
          @playerManager.decisionPoints[playerid] = 2
        # Points for getting the correct solution
        if @playerManager.isRightAnswer(playerid)
          @playerManager.solutionPoints[playerid] = 2
        # Points for being the challenger
        if @playerManager.isChallenger(playerid) && playerid in @state.possiblePlayers
          @playerManager.challengePoints[playerid] = 2
    else
      for playerid in [0...numPlayers]
        if playerid in @state.impossiblePlayers
          @playerManager.decisionPoints[playerid] = 2
        if @playerManager.isChallenger(playerid) && playerid in @state.impossiblePlayers
          @playerManager.challengePoints[playerid] = 2

    # Now add the scores to the player
    for i in [0...numPlayers]
      if(@playerManager.decisionPoints[i]?) then @state.playerScores[i] += @playerManager.decisionPoints[i]
      if(@playerManager.solutionPoints[i]?) then @state.playerScores[i] += @playerManager.solutionPoints[i]
      if(@playerManager.challengePoints[i]?) then @state.playerScores[i] += @playerManager.challengePoints[i]
  
  # A player has said that he is ready for the next round.
  readyForNextRound: (clientid) ->
    index = @playerManager.getPlayerIdBySocket(clientid)
    if(index not in @state.readyForNextRound) then @state.readyForNextRound.push(index)

  # Returns true iff everyone has said they are ready for the next round.
  allNextRoundReady: () -> @state.readyForNextRound.length == @playerManager.players.length

  # sets up the next round in the game, resetting certain values.
  nextRound: ->
    @playerManager.nextRound()

    @goalTree = undefined
    @goalArray = []
    @goalValue = undefined
    @started = false
    @globalDice = []
    @challengeMode = false
    @challengeModeNow = false
    @state.unallocated = []
    @state.required = []
    @state.optional = []
    @state.forbidden = []
    @state.currentPlayer = 0
    @state.possiblePlayers = []
    @state.impossiblePlayers = []
    @state.turnNumber = 0
    @answerExists = false
    @state.readyForNextRound = []
    @goalStart()
    @allocate()

    # check if it's the last round and update the current round
    if @state.currentRound > @state.numRounds then @endGame() else @state.currentRound++

  # Set that the game has ended.
  endGame: ->
    @endOfGame = true

  # Has the game ended? 
  isGameOver: -> @endOfGame or @state.currentRound > @state.numRounds

  # Restart a new round of the game. 
  restartGame: ->
    @nextRound()
    @constructor(@gameNumber, @name, @gameSize, @state.numRounds, @endOfGameCallback)


  module.exports.Game = Game
