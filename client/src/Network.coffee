

class Network
  @initialise: ->
    now.ready ->
      console.log "hello"
      now.addClient()



### Handle events fired by the server ###

###*
 * Called by the server once a player is accepted
 * @param  {String} id The client id returned from the server
 * @param  {Json} diceface The json to tell the client what faces are what numbers
###
now.acceptPlayer = (id, dicefaceSymbols) -> #id is the index
  Game.myPlayerId = id
  DiceFace.symbols = dicefaceSymbols


# this is when the server is telling the client to update his version of the state
now.receiveState = (s) ->
  Game.updateState(s) 

###*
 * Called by the server once sufficient players have joined the game, to start the game.
 * @param  {Player[]} players                 An array of player object
 * @param  {Number[]} unallocated             Array of dicefaces reperesenting the unallocated dicefaces
 * @param  {Number} firstTurnPlayerIndex      The index to this.players that specifies the goal setter
###
now.receiveStartGame = (players, unallocated, firstTurnPlayerIndex) ->
  Game.players = players
  Game.state.unallocated = unallocated
  Game.state.currentplayer = firstTurnPlayerIndex
  if (Game.myPlayerId == firstTurnPlayerIndex) #is this a potential security threat? ie - should we store and compare socketIds instead?
    #  the server sends the id of the first player, and its the same as our id, so we're first
    #  time to set the goal. We need to show the goal settings screen and let the player set the goal
    # show screen
    ScreenSystem.renderScreen(Game.goalScreenId, )

  Game.goingFirst = firstTurnPlayerIndex


###*
 * This is an event triggered by nowjs that says everything's ready to synchronise server/client
###







  


### Fire these events on server ###

###*
 * When client clicks send goal on the gui, call this function
 * @param  {Number[]}  goalArray An array of diceface symbols that specifies the goal
###

sendGoal = (goalArray) -> 
  try
    now.receiveGoal(goalArray) #calls the server function receiveGoal, which parses it and stores it in the server-side game object
  catch e #Catches when wrong client tries to send goal
    console.warn e
  

now.badGoal = (parserMessage) ->
  #do something here to show which part of the goal is malformed
  console.log "Bad goal:"
  console.warn parserMessage

moveToRequired = (index) ->
  now.moveToRequired(index)

moveToOptional = (index) ->
  now.moveToOptional(index)

moveToForbidden = (index) ->
  now.moveToForbidden(index)

