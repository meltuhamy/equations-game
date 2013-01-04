###*
 * nowListener
 * Handle now.js events fired by the server
###

###*
 * Called by the server once a player is accepted
 * @param  {String} id The client id returned from the server
 * @param  {Json} diceface The json to tell the client what faces are what numbers
###
now.acceptPlayer = (id, dicefaceSymbols) -> #id is the index
  Game.myPlayerId = id
  DiceFace.symbols = dicefaceSymbols
  Game.acceptedJoin()


###*
 * Receive list of the games that the server has
 * @param  {Json} gameListJson A json with 
                  nowjsname, roomNumber, playerCount, playerLimit, started
###
now.receiveGameList = (gameListJson) ->
  # TODO: fix this
  Game.updateGameList(gameListJson)

now.receiveMoveTimeUp = () ->
  Game.receiveMoveTimeUp()


###*
 * Called by the server once sufficient players have joined the game, to start the game.
 * @param  {Player[]} players                 An array of player object
 * @param  {Number[]} resources             Array of dicefaces reperesenting the resources dicefaces
 * @param  {Number} goalSetterIndex      The index to this.players that specifies the goal setter
###
now.receiveGoalTurn = (players, resources, goalSetterIndex, timerDuration) ->
  Game.goalTurn(players, resources, goalSetterIndex, timerDuration)
  


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



###*
 * Tell everyone that the turn taking has ended. It's time for a now challenge.
 * In this turn, the players must choose whether they agree or disagree.
 * @param  {Number} challengerId The id if the challenge
###
now.receiveNowChallengeDecideTurn = (challengerId) ->
  Game.receiveNowChallengeDecideTurn(challengerId)
  ScreenSystem.getScreen(Game.gameScreenId).onUpdatedState()

now.receiveNeverChallengeDecideTurn = (challengerId) ->
  Game.receiveNeverChallengeDecideTurn(challengerId)
  ScreenSystem.getScreen(Game.gameScreenId).onUpdatedState()


###*
 * Now that the decision making has finished, ppl who agree send solutions.
 * @param  {Number} challengerId The id if the challenge
###
now.receiveChallengeSolutionsTurn = ->
  Game.receiveChallengeSolutionsTurn()
  ScreenSystem.getScreen(Game.gameScreenId).onUpdatedState()


now.receiveChallengeRoundEndTurn = (solutions, answerExists, challengePts, decisionPts, solutionPts) ->
  Game.receiveChallengeRoundEndTurn(solutions, answerExists, challengePts, decisionPts, solutionPts)
  ScreenSystem.getScreen(Game.gameScreenId).onUpdatedState()

now.receiveEndGame = (solutions, answerExists, challengePts, decisionPts, solutionPts) ->
  Game.receiveEndGame(solutions, answerExists, challengePts, decisionPts, solutionPts)
  ScreenSystem.getScreen(Game.gameScreenId).onUpdatedState()


now.receiveNextRoundAllReady = () ->
  Game.nextRound()

now.receivePlayerDisconnect = (playerId) ->
  Game.removePlayer(playerId)

now.receiveError = (errorObject) ->
  console.log "ERROR HANDLE"
  console.warn(errorObject)
  ScreenSystem.receiveServerError(errorObject)

now.badMove = (serverMessage) ->
  console.warn(serverMessage)

now.badGoal = (parserMessage) ->
  #do something here to show which part of the goal is malformed
  console.warn parserMessage
