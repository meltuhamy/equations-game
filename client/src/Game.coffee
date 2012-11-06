class Game

  # {Player[]} The array of players currently in the game
  @players: undefined

  # {Number} The index of the player whose turn it is
  @firstTurnPlayerIndex: undefined

  # {Number} The unique id of our client player used to communicated with server
  @myPlayerId: undefined

  # {Number[]} The array of dicefaces for the goal when it was set at start of game
  @goal: undefined

  # {Number} The id of the home screen given by the ScreenManager
  # {Number} The id of the goal screen given by the ScreenManager
  @homeScreenId: undefined
  @goalScreenId: undefined
 
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
    @homeScreenId = ScreenSystem.addScreen(new HomeScreen())
    @goalScreenId = ScreenSystem.addScreen(new GoalScreen())

  ###*
   * Set the goal locally. The server has told us the goal-setter has set the goal.
   * @param {Number[]} goal The array of dicefaces for the goal.
  ###
  @setGoal: (goal) ->
    @goal = goal

  ###*
   * Update the game state locally. The server has told us a turn has been made.
   * @param {Json} newState The json of the new state of the game - given by server.
  ###
  @updateState: (newState) ->
    state = newState
