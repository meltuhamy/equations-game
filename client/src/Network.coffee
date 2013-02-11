###*
 * class Network
 * Calls now.js functions on the server.
###
class Network

  # When now.js is ready, tell the Game class its go-time. 
  initialise: ->
    now.ready ->
      Game.onConnection()
      
  # Ask the server to give us a list of games.
  sendGameListRequest: () ->
    now.getGames()


  ###*
   * Tell the server that we want to create a game. Used in lobby screen.
   * @param  {String} gameName      The name of the game that appears on the title screen.
   * @param  {Integer} numberPlayers The number of the players in the game.
   * @param  {String} playerName    The name of the player who is creating the game
   * @param  {Integer} numRounds     The number of rounds in the game
  ###
  sendCreateGameRequest: (gameName, numberPlayers, playerName, numRounds) ->
    now.createGame(gameName, numberPlayers, playerName, numRounds)

  ###*
   * Tell the server that we want to the join a game. Used in lobby screen.
   * @param  {Number[]} goalArray An array of indices to the global dice array.
  ###
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

  ###*
   * Tell the server that we want to move a dice from unallocated to optional
   * @param  {Integer} The index of the diceface within the unallocated array
  ###
  moveToOptional: (index) ->
    now.moveToOptional(index)

  ###*
   * Tell the server that we want to move a dice from unallocated to forbidden
   * @param  {Integer} The index of the diceface within the unallocated array
  ###
  moveToForbidden: (index) ->
    now.moveToForbidden(index)


  ###*
   * It wasn't our turn previously. Tell the server we want to make a now challenge
  ###
  sendNowChallengeRequest: () ->
    now.nowChallengeRequest()

  ###*
   * Tell the server we want to make a never challenge
  ###
  sendNeverChallengeRequest: () ->
    now.neverChallengeRequest()

  ###*
   * Tell the server that we agree to a challenge
   * @return {Boolean} agree whether we agree (true) or disagree with the challenge
  ###
  sendChallengeDecision: (agree) ->
    now.challengeDecision(agree)

  ###*
   * Tell the server our solution to a challenge
   * @return {Integer[]} answer an array of global dice integers that forms our equation
  ###
  sendChallengeSolution: (answer) ->
    now.challengeSolution(answer)

  # Tell the server we are ready for the next round.
  sendNextRoundReady: () ->
    now.nextRoundReady()

  # Pause the timer for the turn (debug purposes)
  pauseTurnTimer: () ->
    now.pauseTurnTimer()

  # Resume a paused timer for the turn (debug purposes)
  # has no effect if the timer has not been paused
  resumeTurnTimer: () ->
    now.resumeTurnTimer()

  # Moves to the next player during allocation turns (debug purposes)
  skipTurn: () ->
    now.skipTurn()

###
# LOOKING FOR now.js listener events? 
# -> Go to nowListener.coffee
###
# Network class is not static. we make a new instance of the network class
# We didn't use a static class as we can't override static methods. 
# We needed to override methods for the tutorial.
network = new Network()