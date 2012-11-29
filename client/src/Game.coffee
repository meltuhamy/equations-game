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
  @gameScreenId: undefined
  @goalScreenId: undefined
  @lobbyScreenId: undefined
  @gameWaitScreenId : undefined

  # {Number} The dice that will be used throughout the game. An array of diceface magic numbers.
  @globalDice: []

  # {Boolean} the index of the player array for the challenger
  @challengeMode: false
  @currentChallengeStage: undefined
  @ChallengeStages: {ChallengeOff: 0, ChallengeDecide:1, ChallengeSolution:2, ChallengeCheck:3}
  @challengerId: undefined

  # Just some functions for everyone to ask us what is going on the challenge?
  @isChallengeDecideTurn: () -> @currentChallengeStage == @ChallengeStages.ChallengeDecide
  @isChallengeSolutionTurn: () -> @currentChallengeStage == @ChallengeStages.ChallengeSolution
  @isChallengeCheckTurn: () -> @currentChallengeStage == @ChallengeStages.ChallengeCheck
  @agreesWithChallenge: () -> @myPlayerId in @state.possiblePlayers
  @isChallenger: () -> @myPlayerId == @challengerId

 
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


  ###*
   * Initialise the game. Add screens. Called localled on page load.
  ###
  @initialise: () ->
    @gameScreenId = ScreenSystem.addScreen(new GameScreen())
    @goalScreenId = ScreenSystem.addScreen(new GoalScreen())
    @lobbyScreenId = ScreenSystem.addScreen(new LobbyScreen())
    @gameWaitScreenId = ScreenSystem.addScreen(new GoalWaitScreen())


  ###*
   * When all the players have joined, it's time to begin. Server call this.
   * @param  {Player[]} players  An array of player objects sent over nowjs (a bit dodgy)
   * @param  {Integer[]} globalDice The global dice for the game.
   * @param  {Integer} firstTurnPlayerId The index to players array of the player who is setting goal.
  ###
  @goalTurn: (players, globalDice, firstTurnPlayerId) ->
    # Set some state variables used for the first turn and will 
    # be updated accordingly on subsequent turns.
    @players = players
    @firstTurnPlayerIndex = firstTurnPlayerId
    @state.currentPlayer = firstTurnPlayerId
    @globalDice = globalDice
    # Am I the player chosen to set the goal? 
    # Yes: show goal setting screen. No: show goal wait screen.
    if (Game.myPlayerId == firstTurnPlayerId) 
      ScreenSystem.renderScreen(Game.goalScreenId, {globalDice: globalDice})
    else
      ScreenSystem.renderScreen(Game.gameWaitScreenId)

  ###*
   * Time for the players to choose if they agree with challenge.
   * @param  {Integer} challengerId The challenger
  ###
  @receiveNowChallengeDecideTurn: (challengerId) ->
    @challengeMode = true
    @currentChallengeStage = @ChallengeStages.ChallengeDecide
    @challengerId = challengerId


  # Time for players to submit solutions.
  @receiveNowChallengeSolutionsTurn: () ->
    @currentChallengeStage = @ChallengeStages.ChallengeSolution










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
    @state = newState

  # Is it currently our turn?
  # @return {Boolean} True if it is our turn and false its someone else's/
  @isMyTurn: () -> @state.currentPlayer == @myPlayerId