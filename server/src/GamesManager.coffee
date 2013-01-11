{Game} = require './Game.js'
{Settings} = require './Settings.js'
{PlayerManager} = require './PlayerManager.js'
class GamesManager


  # List of games
  games: []

  constructor: ()->
    @games = [];

  ###*
   * Get a game by id/index
   * @param  {Number} gameNumber The index of the games array
   * @return {Game} The game object
  ###
  getGame: (gameNumber) ->
    if(gameNumber >= @games.length || gameNumber < 0)
      throw new Error('gameNumber out of bounds')
    return @games[gameNumber]


  ###*
   * Add a new game to the game manager.
   * @return {Number} The identifer for the game
  ###
  newGame: (name, numplayers, numRounds) ->
    @games.push(new Game(@games.length, name, numplayers, numRounds, false))-1


  ###*
   * Returns the list of rooms as a json
   * @return {[type]} [description]
  ###
  getGamesListJson: () ->
    gamesList = [] 
    for g in @games when g?
      gamesList.push
        # the string of the room used by nowjs for unique identification
        nowjsname: g.nowJsGroupName,
        gameName: g.name
        numRounds: g.numRounds
        # index to the games array
        gameNumber: g.gameNumber,
        playerCount: g.getNumPlayers(),
        playerLimit: g.playerManager.playerLimit,
        started: g.started
    return gamesList

  cleanGames: () ->
    startCleanupOn = if Settings.DEBUG then 2 else 0
    for i in [startCleanupOn...@games.length]
      if @games[i]? && @games[i].playerManager.players.length == 0
        @games[i] = undefined


module.exports.GamesManager = GamesManager
