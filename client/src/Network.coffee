###*
 * class Network
 * Calls now.js functions on the server.
###
class Network
  initialise: ->
    now.ready ->
      Game.onConnection()
      
  sendGameListRequest: () ->
    now.getGames()

  sendCreateGameRequest: (gameName, numberPlayers, playerName, numRounds) ->
    now.createGame(gameName, numberPlayers, playerName, numRounds)

  sendJoinGameRequest: (gameNumber, screenName) ->
    now.addClient(gameNumber, screenName)

  ###*
   * Sends the goal array to the server
   * @param  {Number[]} goalArray An array of indices to the global dice array.
  ###
  sendGoal: (goalArray) ->
    now.receiveGoal(goalArray) #calls the server function receiveGoal, which parses it and stores it in the server-side game object


  ###*
   * Tell the server that we want to move a dice from unallocated to required
   * @param  {Integer} The index of the diceface within the unallocated array
  ###
  moveToRequired: (index) ->
    now.moveToRequired(index)

  moveToOptional: (index) ->
    now.moveToOptional(index)

  moveToForbidden: (index) ->
    now.moveToForbidden(index)

  # It wasn't our turn previously. Tell the server we want to make a now challenge
  sendNowChallengeRequest: () ->
    now.nowChallengeRequest()

  # It wasn't our turn previously. Tell the server we want to make a never challenge
  sendNeverChallengeRequest: () ->
    now.neverChallengeRequest()

  sendChallengeDecision: (agree) ->
    now.challengeDecision(agree)

  sendChallengeSolution: (answer) ->
    now.challengeSolution(answer)

  sendNextRoundReady: () ->
    now.nextRoundReady()

  pauseTurnTimer: () ->
    now.pauseTurnTimer()

  resumeTurnTimer: () ->
    now.resumeTurnTimer()

  skipTurn: () ->
    now.skipTurn()

###
# LOOKING FOR now.js listener events? 
# -> Go to nowListener.coffee
###

network = new Network()