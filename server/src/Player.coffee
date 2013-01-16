class Player
  # {String} the name of the player (as it appears on the screen)
  name: ''
  # {Index}  the index (id) of the player used in 
  index: undefined
  # {Integer}  The number of missed turns (by taking too long).   
  turnMisses: 0
  # {Integer}  The number of consecutive missed turns.  
  consecutiveTurnMisses: 0
  # {Integer}  The total number of allocation moves made.
  movesPlayed: 0

  constructor: (@index, @name) ->

module.exports.Player = Player;
