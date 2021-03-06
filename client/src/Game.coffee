###*
 * class Game
###
class Game

  # {Player[]} The array of players currently in the game
  @players: undefined

  # {Number} The index of the player whose turn it is
  @firstTurnPlayerIndex: undefined

  # {Number} The index to the players array 
  @myPlayerId: undefined

  # {Number[]} The array of dicefaces for the goal when it was set at start of game
  @goal: undefined

  # {Number} The id of screens given by the ScreenManager and used for the ScreenManager
  @lobbyScreenId: undefined
  @joinWaitScreenId: undefined
  @gameScreenId: undefined
  @goalScreenId: undefined
  @endRoundScreenId: undefined
  @endGameScreenId: undefined
  @gameWaitScreenId : undefined
  @tutorialLobbyScreenId: undefined
  @tutorialGoalScreenId: undefined

  # {Json[]} A log of all the commentary.
  @commentaryLog: []


  # {Number} The dice that will be used throughout the game. An array of diceface magic numbers.
  @globalDice: []

  # {Json} A json for the list of rooms sent by the server.
  @gameList: []


  # {Number} the index of the player array for the challenger
  @challengerId: undefined

  # {Boolean} has a challenge been declared yet for the current round?
  @challengeMode: false
  @currentChallengeStage: undefined
  @ChallengeStages: {ChallengeOff: 0, ChallengeDecide:1, ChallengeSolution:2, ChallengeCheck:3, ChallengeEnd: 4}
  
  # Is the challenge a now challenge or a never challenge? Assumes challengeMode = true
  @challengeModeNow = undefined
  @getChallengeName: () ->
    if(!@challengeMode) then return ''
    if(@challengeModeNow) then return 'Now Challenge' else return 'Never Challenge'


  # Just some functions for everyone to ask us what is going on the challenge?
  @isChallengeDecideTurn: () -> @currentChallengeStage == @ChallengeStages.ChallengeDecide
  @isChallengeSolutionTurn: () -> @currentChallengeStage == @ChallengeStages.ChallengeSolution
  @isChallengeCheckTurn: () -> @currentChallengeStage == @ChallengeStages.ChallengeCheck
  @agreesWithChallenge: () -> (@myPlayerId in @state.possiblePlayers && @challengeModeNow) || (@myPlayerId in @state.impossiblePlayers && !@challengeModeNow)
  @hasPlayerDecided: (index) -> (index in @state.possiblePlayers || index in @state.impossiblePlayers)
  @doesPlayerAgreeChallenge: (index) -> (index in @state.possiblePlayers && @challengeModeNow) || (index in @state.impossiblePlayers && !@challengeModeNow)

  @isChallenger: () -> @myPlayerId == @challengerId
  @solutionRequired: -> (@agreesWithChallenge() && @challengeModeNow) || (!@agreesWithChallenge() && !@challengeModeNow)

  @getPlayerByName: (index) -> @players[index].name
  @getCurrentTurnPlayerName: () -> @players[@state.currentPlayer].name

 
  # {Json} The json of the current state of the game and what type each dice is.
  # unallocated, required, optional, forbidden are arrays of dicefaces.
  # currentPlayer is the index of the player whose turn it currently is
  @state:
    unallocated: []
    required: []
    optional: []
    forbidden: []
    # index of player whose turn it is. incremented after each resource move
    currentPlayer: 0
    # {Number[]} array of indices to player array of the players who think now challenge possible
    possiblePlayers: []
    # {Number[]} array of indices to player array of the players who think now challenge not possible
    impossiblePlayers: []
     # {Date} The Unix timestamp of when the current turn started
    turnStartTime: undefined
    # {Number} The duration of the current turn in seconds
    turnDuration: undefined
    playerScores: []
    # {Number} The current round
    currentRound: undefined
    # {Number} The total number of rounds
    numRounds: undefined


  ###*
   * Initialise the game. Add screens. Called localled on page load.
  ###
  @onDocumentReady: () ->
    @lobbyScreenId = ScreenSystem.addScreen(new LobbyScreen())
    @joinWaitScreenId = ScreenSystem.addScreen(new JoinWaitScreen())
    @gameScreenId = ScreenSystem.addScreen(new GameScreen())
    @goalScreenId = ScreenSystem.addScreen(new GoalScreen())
    @gameWaitScreenId = ScreenSystem.addScreen(new GoalWaitScreen())
    @endRoundScreenId = ScreenSystem.addScreen(new EndRoundScreen())
    @endGameScreenId = ScreenSystem.addScreen(new EndGameScreen())

    # Tutorial screens
    @tutorialLobbyScreenId = ScreenSystem.addScreen(new TutorialLobbyScreen)
    @tutorialGoalScreenId = ScreenSystem.addScreen(new TutorialGoalScreen)
    @tutorialGameScreenId = ScreenSystem.addScreen(new TutorialGameScreen)


  @onConnection: () ->
    network.sendGameListRequest()
    ScreenSystem.renderScreen(@lobbyScreenId)

  # Update the gamelist json - the list of info about all games in lobby.
  @updateGameList: (gameListJson) -> 
    @gameList = gameListJson
    ScreenSystem.getCurrentScreen().onUpdatedGameList(@gameList)
    
    
  @joinGame: (gameNumber, screenName) ->
    network.sendJoinGameRequest(gameNumber, screenName)

  @acceptedJoin: () ->
    ScreenSystem.renderScreen(@joinWaitScreenId)


  @addCommentaryToLog: (commentaryJson) ->
    @commentaryLog.push commentaryJson


  ###*
   * The server told us we took too long
  ###
  @receiveMoveTimeUp: () ->
    console.log "PLAYER TOOK TOO LONG!!!!"



  ###*
   * When all the players have joined, it's time to begin. Server call this.
   * @param  {Player[]} players  An array of player objects sent over nowjs (a bit dodgy)
   * @param  {Integer[]} globalDice The global dice for the game.
   * @param  {Integer} firstTurnPlayerId The index to players array of the player who is setting goal.
  ###
  @goalTurn: (players, globalDice, firstTurnPlayerId, timerDuration) ->
    # Set some state variables used for the first turn and will 
    # be updated accordingly on subsequent turns.
    @players = players
    @firstTurnPlayerIndex = firstTurnPlayerId
    @state.currentPlayer = firstTurnPlayerId
    @globalDice = globalDice
    # Am I the player chosen to set the goal? 
    # Yes: show goal setting screen. No: show goal wait screen.
    if (Game.myPlayerId == firstTurnPlayerId) 
      ScreenSystem.renderScreen(Game.goalScreenId, {globalDice: globalDice, timerDuration: timerDuration})
    else
      ScreenSystem.renderScreen(Game.gameWaitScreenId, {timerDuration: timerDuration})

  ###*
   * Time for the players to choose if they agree with challenge.
   * @param  {Integer} challengerId The challenger
  ###
  # TODO: Factorise this
  @receiveNowChallengeDecideTurn: (challengerId) ->
    @challengeMode = true
    @currentChallengeStage = @ChallengeStages.ChallengeDecide
    @challengerId = challengerId
    @challengeModeNow = true

  @receiveNeverChallengeDecideTurn: (challengerId) ->
    @challengeMode = true
    @currentChallengeStage = @ChallengeStages.ChallengeDecide
    @challengerId = challengerId
    @challengeModeNow = false



  # Time for players to submit solutions.
  @receiveChallengeSolutionsTurn: () ->
    @currentChallengeStage = @ChallengeStages.ChallengeSolution

  @receiveChallengeRoundEndTurn: (solutions, answerExists, challengePts, decisionPts, solutionPts) ->
    @currentChallengeStage = @ChallengeStages.ChallengeEnd
    if @state.currentRound >= @state.numRounds
      @receiveEndGame(solutions, answerExists, challengePts, decisionPts, solutionPts)
    else 
      ScreenSystem.renderScreen @endRoundScreenId,
        solutions: solutions
        answerExists:answerExists
        challengePts:challengePts
        decisionPts:decisionPts
        solutionPts: solutionPts

  @receiveEndGame: (solutions, answerExists, challengePts, decisionPts, solutionPts) ->
    ScreenSystem.renderScreen @endGameScreenId,
      solutions: solutions
      answerExists:answerExists
      challengePts:challengePts
      decisionPts:decisionPts
      solutionPts: solutionPts

  ###*
   * Set the goal locally. The server has told us the goal-setter has set the goal.
   * @param {Number[]} goal The array of indices to the resources array for the goal.
  ###
  @setGoal: (goal) ->
    @goal = goal


  ###*
   * Get the diceface values for the goal. 
   * @return {Number} This returns the actual values rather than indices in an array.
  ###
  @getGoalValues: () ->
    diceValues = []
    for g in @goal
      if(g == -1) then diceValues.push (DiceFace.symbols.bracketL) 
      else if(g == -2) then diceValues.push (DiceFace.symbols.bracketR) 
      else diceValues.push (@globalDice[g]) 
    return diceValues


  # Return the game state Json
  @getState: () -> 
    return @state


  ###*
   * Update the game state locally. The server has told us a turn has been made.
   * @param {Json} newState The json of the new state of the game - given by server.
  ###
  @updateState: (newState) ->
    prevstate = @state
    @state = newState
    ScreenSystem.getCurrentScreen().onUpdatedState() 
    if(newState.currentPlayer != prevstate.currentPlayer)
      ScreenSystem.getCurrentScreen().onUpdatedPlayerTurn() 
 
 
  # Is it currently our turn?
  # @return {Boolean} True if it is our turn and false its someone else's/
  @isMyTurn: () -> @state.currentPlayer == @myPlayerId

  @removePlayer: (index) ->
    if @players.length == 2
      alert "Not enough players in game, taking you back to lobby!"
      location.reload()
    else
      for i in [(index + 1) ... @players.length]
        @players[i].index--
      @players.splice(index,1)
      console.log "spliced"
      if @myPlayerId > index
        @myPlayerId--


  ###*
   * Resets all variables
  ###
  @nextRound: () ->
    @players = undefined
    @firstTurnPlayerIndex = undefined
    @goal = undefined
    @globalDice = []
    @gameList = []
    @challengeMode = false
    @currentChallengeStage = undefined
    @challengerId = undefined
    @challengeModeNow = undefined
    @commentaryLog = []
    
