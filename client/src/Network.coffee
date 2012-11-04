
### Handle events fired by the server ###

###*
 * Called by the server once a player is accepted
 * @param  {String} id The client id returned from the server
###
now.acceptPlayer = (id, diceface) ->
  game.myPlayerId = id
  game.dicefaces = diceface


# this is when the server is telling the client to update his version of the state
now.receiveState = (s) ->
  game.updateState(s) 

###*
 * Called by the server once sufficient players have joined the game, to start the game.
 * @param  {Player[]} players                 An array of player object
 * @param  {Number[]} unallocated             Array of dicefaces reperesenting the unallocated dicefaces
 * @param  {Number} firstTurnPlayerIndex      The index to this.players that specifies the goal setter
###
now.receiveStartGame = (players, unallocated, firstTurnPlayerIndex) ->
  game.players = players
  game.state.unallocated = unallocated
  game.state.currentplayer = firstTurnPlayerIndex
  if (game.myPlayerId == firstTurnPlayerIndex)
    #  the server sends the id of the first player, and its the same as our id, so we're first
    #  time to set the goal. We need to show the goal settings screen and let the player set the goal
    # show screen
    ui.showUnallocated(unallocated) # convert the unallocated array to html and display on the screen

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

moveToRequired = (resource) ->
  now.moveToRequired(resource)

moveToOptional = (resource) ->
  now.moveToOptional(resource)

moveToForbidden = (resource) ->
  now.moveToForbidden(resource)

