

class Network
  @initialise: ->
    now.ready ->
      now.getGames()


  @sendJoinGameRequest: (gameNumber) ->
    now.addClient(gameNumber)

  ###*
   * Sends the goal array to the server
   * @param  {Number[]} goalArray An array of indices to the global dice array.
  ###
  @sendGoal: (goalArray) ->
    try
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

  # It wasn't our turn previously. Tell the server we want to make a now challenge
  @sendNowChallengeRequest : () ->
    now.nowChallengeRequest()

  # Tell the server our decision for the now challenge. isPossible=true if we think is possible
  @sendNowChallengeDecision : (isPossible) ->
    now.nowChallengeDecision(isPossible)





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
  Game.goalTurn(players, resources, firstTurnPlayerIndex)
  


###*
 * This is when the server is telling the client to update his goal because the goal setter set the goal.
 * @param  {goalArray}
###
now.receiveGoalTurnEnd = (goalArray) ->
  Game.setGoal(goalArray)
  ScreenSystem.renderScreen(Game.gameScreenId)



###*
 * This is when the server is telling the client to update his version of the state when a turn ends.
 * @param  {Json} state A json containing varaibles holding the state of the game.
 *                  Is of the format: {unallocated: [], required: [], 
 *                                     optional: [], forbidden: [], currentPlayer: Integer}
###
now.receiveState = (state) ->
  Game.updateState(state)
  ScreenSystem.getScreen(Game.gameScreenId).onUpdatedState()



###*
 * Tell everyone that the turn taking has ended. It's time for a now challenge.
 * In this turn, the players must choose whether they agree or disagree.
 * @param  {Number} challengerId The id if the challenge
###
now.receiveNowChallengeDecideTurn = (challengerId) ->
  Game.receiveNowChallengeDecideTurn(challengerId)
  ScreenSystem.getScreen(Game.gameScreenId).onUpdatedState()


###*
 * Update everyone with a new decision that somebody make.
 * @param  {Number} challengerId The id if the player who made a decision
 * @param  {Number} isPossible Whether it is true or not
###
now.receiveNowChallengeDecision = (clientid, isPossible) ->
  Game.receiveNowChallengeDecision(clientid, challengerId)
  ScreenSystem.getScreen(Game.gameScreenId).onUpdatedState()


###*
 * Now that the decision making has finished, ppl who agree send solutions.
 * @param  {Number} challengerId The id if the challenge
###
now.receiveNowChallengeSolutionsTurn = (challengerId) ->
  Game.receiveNowChallengeDecideTurn(challengerId)
  ScreenSystem.getScreen(Game.gameScreenId).onUpdatedState()







###*
 * This is an event triggered by nowjs that says everything's ready to synchronise server/client
###








  


### Fire these events on server ###


now.badMove = (serverMessage) ->
  alert(serverMessage)

now.badGoal = (parserMessage) ->
  #do something here to show which part of the goal is malformed
  console.log "Bad goal:"
  console.warn parserMessage


