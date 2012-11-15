

class Network
  @initialise: ->
    now.ready ->
      now.getGames()


  @sendJoinGameRequest: (gameNumber) ->
    now.addClient(gameNumber)

  ###*
   * Sends the goal array to the server
   * @param  {Number[]} goalArray An array of indices to the resources array.
  ###
  @sendGoal: (goalArray) ->
    try
      console.log goalArray
      now.receiveGoal(goalArray) #calls the server function receiveGoal, which parses it and stores it in the server-side game object
    catch e #Catches when wrong client tries to send goal
      console.warn e

  ###*
   * Tell the server that we want to move a dice from unallocated to required
   * @param  {Integer} The index of the diceface within the unallocated array
  ###
  @moveToRequired : (index) ->
    now.moveToRequired(index)

  @moveToOptional : (index) ->
    now.moveToOptional(index)

  @moveToForbidden : (index) ->
    now.moveToForbidden(index)





### Handle events fired by the server ###

###*
 * Called by the server once a player is accepted
 * @param  {String} id The client id returned from the server
 * @param  {Json} diceface The json to tell the client what faces are what numbers
###
now.acceptPlayer = (id, dicefaceSymbols) -> #id is the index
  Game.myPlayerId = id
  DiceFace.symbols = dicefaceSymbols





###*
 * Receive list of the games that the server has
 * @param  {Json} gameListJson A json with 
                  nowjsname, roomNumber, playerCount, playerLimit, started
###
now.receiveGameList = (gameListJson) ->
  ScreenSystem.renderScreen(Game.lobbyScreenId, {gameListJson: gameListJson})




###*
 * Called by the server once sufficient players have joined the game, to start the game.
 * @param  {Player[]} players                 An array of player object
 * @param  {Number[]} resources             Array of dicefaces reperesenting the resources dicefaces
 * @param  {Number} firstTurnPlayerIndex      The index to this.players that specifies the goal setter
###
now.receiveGoalTurn = (players, resources, firstTurnPlayerIndex) ->
  Game.players = players
  Game.firstTurnPlayerIndex = firstTurnPlayerIndex
  Game.state.currentplayer = firstTurnPlayerIndex
  Game.state.unallocated = resources

  if (Game.myPlayerId == firstTurnPlayerIndex) 
    # is this a potential security threat? ie - should we store and compare socketIds instead?
    #  the server sends the id of the first player, and its the same as our id, so we're first
    #  time to set the goal. We need to show the goal settings screen and let the player set the goal
    # show screen
    ScreenSystem.renderScreen(Game.goalScreenId, {resources: resources})
  else
    #ScreenSystem.renderScreen(waitingScreen)

  Game.goingFirst = firstTurnPlayerIndex


###*
 * This is when the server is telling the client to update his goal because the goal setter set the goal.
 * @param  {goalArray}
###
now.receiveGoalTurnEnd = (goalArray) ->
  Game.setGoal(goalArray)
  console.log goalArray
  ScreenSystem.renderScreen(Game.homeScreenId, {goal: goalArray})



###*
 * This is when the server is telling the client to update his version of the state when a turn ends.
 * @param  {Json} state A json containing varaibles holding the state of the game.
 *                  Is of the format: {unallocated: [], required: [], 
 *                                     optional: [], forbidden: [], currentPlayer: Integer}
###
now.receiveState = (state) ->
  Game.updateState(state)
  ScreenSystem.getScreen(Game.homeScreenId).drawDiceAllocations()








###*
 * This is an event triggered by nowjs that says everything's ready to synchronise server/client
###








  


### Fire these events on server ###


  

now.badGoal = (parserMessage) ->
  #do something here to show which part of the goal is malformed
  console.log "Bad goal:"
  console.warn parserMessage


