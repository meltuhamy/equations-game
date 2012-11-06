class Game
  @players: undefined
  @firstTurnPlayerIndex: undefined
  @myPlayerId: undefined
  @goal: undefined
  @homeScreenId: undefined
  @goalScreenId: undefined
 
  @state: 
    unallocated: []
    required: []
    optional: []
    forbidden: []
    currentPlayer: 0

  @initialise: () ->
    @homeScreenId = ScreenSystem.addScreen(new HomeScreen())
    @goalScreenId = ScreenSystem.addScreen(new GoalScreen())

  @setGoal: (goal) ->
    @goal = goal

  @updateState: (newState) ->
    state = newState
