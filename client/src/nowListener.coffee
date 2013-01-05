###*
 * nowListener
 * Handle now.js events fired by the server
###

###*
 * Called by the server once a player is accepted
 * @param  {String} id The client id returned from the server
 * @param  {Json} diceface The json to tell the client what faces are what numbers
 * @param  {Json} errorCodes The json to giving the client the meaning of error numbers
###
now.acceptPlayer = (id, dicefaceSymbols, errorCodes) -> #id is the index
  Game.myPlayerId = id
  DiceFace.symbols = dicefaceSymbols
  ErrorManager.codes = errorCodes
  Game.acceptedJoin()


###*
 * Receive list of the games that the server has
 * @param  {Json} gameListJson A json with 
                  nowjsname, roomNumber, playerCount, playerLimit, started
###
now.receiveGameList = (gameListJson) ->
  # TODO: fix this
  Game.updateGameList(gameListJson)

# Turn has moved on because the player whose turn it was took too long
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
  #Commentary.logGoalTurn(goalArray)


###*
 * This is when the server is telling the client to update his goal because the goal setter set the goal.
 * @param  {goalArray}
###
now.receiveGoalTurnEnd = (goalArray) ->
  Game.setGoal(goalArray)
  ScreenSystem.renderScreen(Game.gameScreenId)
  Commentary.logGoalFormed(goalArray)


###*
 * This is when the server is telling the client to update his version of the state when a turn ends.
 * @param  {Json} state A json containing varaibles holding the state of the game.
 *                      See Game.coffee for the format of the json
###
now.receiveState = (state) ->
  Game.updateState(state)

now.receiveMoveToRequired = (moverId, index) ->
  Commentary.logMoveToRequired(moverId, index)

now.receiveMoveToOptional = (moverId, index) ->
  Commentary.logMoveToOptional(moverId, index)

now.receiveMoveToForbidden = (moverId, index) ->
  Commentary.logMoveToForbidden(moverId, index)



###*
 * Tell everyone that the turn taking has ended. It's time for a now challenge.
 * In this turn, the players must choose whether they agree or disagree.
 * @param  {Number} challengerId The id of the challenger
###
now.receiveNowChallengeDecideTurn = (challengerId) ->
  Game.receiveNowChallengeDecideTurn(challengerId)
  ScreenSystem.getScreen(Game.gameScreenId).onUpdatedState()
  Commentary.logNowChallenge(challengerId)

###*
 * Tell everyone that the turn taking has ended. It's time for a never challenge.
 * In this turn, the players must choose whether they agree or disagree.
 * @param  {Number} challengerId The id of the challenger
###
now.receiveNeverChallengeDecideTurn = (challengerId) ->
  Game.receiveNeverChallengeDecideTurn(challengerId)
  ScreenSystem.getScreen(Game.gameScreenId).onUpdatedState()
  Commentary.logNeverChallenge(challengerId)


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
  console.log "Player Disconnected"
  if(playerId == Game.myPlayerId)
    window.location.reload()
  else
    Game.removePlayer(playerId)

now.receiveError = (errorObject) ->
  console.warn(errorObject)
  ScreenSystem.receiveServerError(errorObject)

now.badMove = (serverMessage) ->
  console.warn(serverMessage)

now.badGoal = (parserMessage) ->
  #do something here to show which part of the goal is malformed
  console.warn parserMessage
