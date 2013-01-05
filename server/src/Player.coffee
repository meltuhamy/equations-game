class Player
  name: ''
  index: undefined
  turnMisses: 0
  consecutiveTurnMisses: 0
  movesPlayed: 0

  constructor: (@index, @name) ->

module.exports.Player = Player;
