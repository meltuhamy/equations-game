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

 
  # {Json} The json of the current state of the game and what type each dice is.
  # unallocated, required, optional, forbidden are arrays of dicefaces.
  # currentPlayer is the index of the player whose turn it currently is
  @state: 
    unallocated: []
    required: []
    optional: []
    forbidden: []
    currentPlayer: 0

  ###*
   * Initialise the game. Add screens.
  ###
  @initialise: () ->
    @gameScreenId = ScreenSystem.addScreen(new GameScreen())
    @goalScreenId = ScreenSystem.addScreen(new GoalScreen())
    @lobbyScreenId = ScreenSystem.addScreen(new LobbyScreen())
    @gameWaitScreenId = ScreenSystem.addScreen(new GoalWaitScreen())

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
      console.log DiceFace
      if(g == -1) then diceValues.push (DiceFace.symbols.bracketL) 
      else if(g == -2) then diceValues.push (DiceFace.symbols.bracketR) 
      else diceValues.push (@state.unallocated[g]) 
    console.log diceValues
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