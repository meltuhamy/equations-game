class PlayerManager

  # {Player[]} An array of players who have joined the game
  players: []

  # {Number} The nowjs sockets for players. These match up index-by-index with players array
  playerSocketIds: []

  # {Number} The maximum number of players allow in the game.
  playerLimit: 2

  # {Number} An index to players array. Player who sets the goal (takes the goal setting turn)
  goalSetter: undefined

  # {Number} the index of the player array for the challenger
  challenger: undefined

  # {Number []} An array of player indices that have submitted solutions during a challenge
  submittedSolutions: []

  # {Number []} An array of player indices that have submitted correct answers during a challenge
  rightAnswers: []

  constructor: ->
    @players = []
    @playerSocketIds = []
    @playerLimit = 2
    @goalSetter = undefined
    @challenger = undefined
    @submittedSolutions = []
    @rightAnswers = []

  # Convert a player id to a socketid and vica versa
  getPlayerIdBySocket: (socket) -> @playerSocketIds.indexOf(socket)
  getPlayerSocketById: (id) -> @playerSocketIds[id]

module.exports.PlayerManager = PlayerManager
