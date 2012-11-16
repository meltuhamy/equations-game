{app, server, nowjs} = require './ServerListener.js'

{DiceFace}  = require './DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols

{Game} = require './Game.js'
{Player} = require './Player.js'
{GamesManager} = require './GamesManager.js'

everyone = nowjs.initialize(server)

gamesManager = new GamesManager()
gamesManager.newGame()

# Returns a pair {game,group} specifying the game and group for the given gameNumber
getThisGameGroup = (gameNumber) =>
  game = gamesManager.getGame(gameNumber)
  group = nowjs.getGroup(game.nowJsGroupName)
  return {game: game, group: group}
    

###
everyone.now.createGame = (jsonParams) ->
  games.push(new Game(jsonParams))
  this.now.addClient(games.length-1)
###


everyone.now.addClient = (gameNumber) -> #called by client when connected
  {game, group} = getThisGameGroup(gameNumber)
  if(!game.isFull())
    # add the player to the nowjs group
    group.addUser(this.user.clientId)

    # place the gameNumber in the client pocket
    this.now.gameNumber = gameNumber

    # add the player to the game, tell him he was accepted and give him his playerId (i.e. index) for the game
    this.now.acceptPlayer(game.addClient(this.user.clientId), DICEFACESYMBOLS)

    # Now see if the game is full after adding him (i.e see if is the last player)
    # If it is, then tell everyone in this game that its the goal setting turn. 
    if(game.isFull())
      group.now.receiveGoalTurn(game.players, game.state.unallocated, game.getFirstTurnPlayer())
  else
    # else the game is already full, so tell him - tough luck



everyone.now.getGames = ->
  gamesList = gamesManager.getGamesListJson()
  this.now.receiveGameList(gamesList)





###*
 * Recieves the goal array from client
 * This is when the goal setter sends his goal. We tell everyone what the goal is.
 * @param  {[type]} goalArray [description]
 * @return {[type]}           [description]
###
everyone.now.receiveGoal = (goalArray) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)

  if !(this.user.clientId == game.playerSocketIds[game.goalSetter])
    throw "Unauthorised goal setter"
  try
    game.setGoal(goalArray)
    everyone.now.receiveGoalTurnEnd(goalArray)
  catch e #catches when parser returns error for goal
    this.now.badGoal(e.message)



everyone.now.moveToRequired = (index) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  try
    game.moveToRequired(index, this.user.clientId)
    group.now.receiveState(game.state)
  catch e
    console.warn e

everyone.now.moveToOptional = (index) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  try
    game.moveToOptional(index, this.user.clientId)
    group.now.receiveState(game.state)
  catch e
    console.warn e

everyone.now.moveToForbidden = (index) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  try
    game.moveToForbidden(index, this.user.clientId)
    group.now.receiveState(game.state)
  catch e
    console.warn e
  

everyone.now.logStuff = (message) ->
  console.log message

everyone.now.testFunc = () ->
  console.log(this.user.addClient)