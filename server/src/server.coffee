{app, server, nowjs} = require './ServerListener.js'

{DiceFace}  = require './DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols

{Game} = require './Game.js'
{Player} = require './Player.js'

everyone = nowjs.initialize(server)


game = new Game([], 50)
games = [game]

###
everyone.now.createGame = (jsonParams) ->
  games.push(new Game(jsonParams))
  this.now.addClient(games.length-1)
###

###
FIIIIIIIIIIIIIIX THIS NOW
###
everyone.now.addClient = (gameNumber) -> #called by client when connected
  if(!game.isFull())
    # add the player, tell him he was accepted and give him his playerId (i.e. index) for the game
    this.now.acceptPlayer(game.addClient(this.user.clientId), DICEFACESYMBOLS)
    # Now see if the game is full after adding him (i.e see if is the last player)
    # If it is, then tell everyone that its the goal setting turn. 
    if(game.isFull())
      everyone.now.receiveGoalTurn(game.players, game.state.unallocated, game.getFirstTurnPlayer())
  else
    # else the game is already full, so tell him - tough luck



everyone.now.getGames = ->
  console.log "getGames!!!"
  gamesList = []
  for g in games
    gameData = {
      # the string of the room used by nowjs for unique identification
      nowjsname: g.nowJsGroupName,
      # index to the games array
      gameNumber: g.gameNumber,
      playerCount: g.getNumPlayers(),
      playerLimit: g.playerLimit,
      started: g.started
    }
    gamesList.push gameData
  this.now.receiveGameList(gamesList)





###*
 * Recieves the goal array from client
 * This is when the goal setter sends his goal. We tell everyone what the goal is.
 * @param  {[type]} goalArray [description]
 * @return {[type]}           [description]
###
everyone.now.receiveGoal = (goalArray) -> #
  if !(this.user.clientId == game.playerSocketIds[game.goalSetter])
    throw "Unauthorised goal setter"
  try
    game.setGoal(goalArray)
    everyone.now.receiveGoalTurnEnd(goalArray)
  catch e #catches when parser returns error for goal
    this.now.badGoal(e.message)



everyone.now.moveToRequired = (index) ->
  try
    game.moveToRequired(index, this.user.clientId)
    everyone.now.receiveState(game.state)
  catch e
    console.warn e

everyone.now.moveToOptional = (index) ->
  try
    game.moveToOptional(index, this.user.clientId)
    everyone.now.receiveState(game.state)
  catch e
    console.warn e

everyone.now.moveToForbidden = (index) ->
  try
    game.moveToForbidden(index, this.user.clientId)
    everyone.now.receiveState(game.state)
  catch e
    console.warn e
  

everyone.now.logStuff = (message) ->
  console.log message

everyone.now.testFunc = () ->
  console.log(this.user.addClient)