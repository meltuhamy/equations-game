class Game
  dicefaces: undefined
  players: undefined
  firstTurnPlayerIndex: undefined
  myPlayerId: undefined
  goal: undefined
  state: 
    unallocated: []
    required: []
    optional: []
    forbidden: []
    currentPlayer: 0
  constructor: () ->
  setGoal: (goal) ->
    @goal = goal
  updateState: (newState) ->
    state = newState
  
game = undefined