{Game} = require './Game.js'
class GamesManager
  games: []
  getGame: (gameNumber) ->
    if(gameNumber >= @games.length || gameNumber < 0)
      throw new Error('gameNumber out of bounds')
    return @games[gameNumber]
  newGame: () ->
    @games.push new Game([], @games.length)
  getGamesListJson: () ->
    gamesList = [] 
    for g in @games
      gamesList.push
        # the string of the room used by nowjs for unique identification
        nowjsname: g.nowJsGroupName,
        # index to the games array
        gameNumber: g.gameNumber,
        playerCount: g.getNumPlayers(),
        playerLimit: g.playerLimit,
        started: g.started
    return gamesList

module.exports.GamesManager = GamesManager
