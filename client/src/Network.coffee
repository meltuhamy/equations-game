goal = undefined
state = undefined 
game = undefined


### Handle events fired by the server ###

###*
 * Called by the server once a player is accepted
 * @param  {String} id The client id returned from the server
###
now.acceptPlayer = (id, diceface) ->
  game.myPlayerId = id
  game.dicefaces = diceface


now.receiveState = (s) ->
  state = s

###*
 * Called by the server once sufficient players have joined the game, to start the game.
 * @param  {JSON object} diceJson             Lets you use stuff like diceJson.one etc.
 * @param  {Player[]} players                 An array of player object
 * @param  {Number} firstTurnPlayerIndex      The index to this.players that specifies the goal setter
###
now.receiveStartGame = (players, firstTurnPlayerIndex) ->
  game.players = players
  game.goingFirst = firstTurnPlayerIndex

###*
 * This is an event triggered by nowjs that says everything's ready to synchronise server/client
###
now.ready ->
  game = new Game()
  now.addClient()


### Fire these events on server ###

###*
 * When client clicks send goal on the gui, call this function
 * @param  {Number[]}  goalArray An array of diceface symbols that specifies the goal
###

sendGoal = (goalArray) -> 
  now.receiveGoal(goalArray) #calls the server function receiveGoal, which parses it and stores it in the server-side game object

now.badGoal = (message) ->
  console.log message



