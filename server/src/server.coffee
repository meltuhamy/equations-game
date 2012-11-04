{app, server, nowjs} = require './ServerListener.js'

{DICEFACES}  = require './DiceFace.js'
DICEFACESYMBOLS = DICEFACES.symbols

{Game} = require './Game.js'
{Player} = require './Player.js'

everyone = nowjs.initialize(server)


game = new Game([])

everyone.now.addClient = () -> #called by client when connected
  if(!game.isFull())
    # add the player, tell him he was accepted and give him his playerId for the game
    assignedPlayerId = game.addClient(this.user.clientId)
    this.now.acceptPlayer(assignedPlayerId, DICEFACESYMBOLS)
    #now see if the game is full after adding him (i.e see if is the last player)
    if(game.isFull())
      everyone.now.receiveStartGame(game.players, 0)
  else
    # else the game is already full, so tell him - tough luck

    
 
everyone.now.receiveGoal = (goalArray) -> #recieves the goal array from client
  #need to validate goal array at some point
  try
    game.setGoal(goalArray)
  catch e
    this.now.badGoal("Bad goal:" + e)
  

everyone.now.moveToRequired = (resource) ->
  game.moveToRequired(resource)
  everyone.now.receiveState(game.state)

everyone.now.moveToOptional = (resource) ->
  game.moveToOptional(resource)
  everyone.now.receiveState(game.state)

everyone.now.moveToForbidden = (resource) ->
  game.moveToForbidden(resource)
  everyone.now.receiveState(game.state)
  

everyone.now.logStuff = (message) ->
  console.log message

everyone.now.testFunc = () ->
  console.log(this.user.addClient)

###
flatten = (node) ->
  str = ""
  if node.children then str += "["
  str+= " "
  str += DICEFACES.getString node.token
  if node.children
    str+=" "
    str += flatten(child) for child in node.children
  str+= " "
  if node.children then str +="]"
  str

prettyPrint = (node) -> console.log flatten(node)
module.exports.prettyPrint = prettyPrint
###