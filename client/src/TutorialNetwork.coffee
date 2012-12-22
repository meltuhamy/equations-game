###*
 * class TutorialNetwork extends Network
 * Pretends to know what the server does and just does client calls
###
class TutorialNetwork extends Network
  initialise: ->
    now.ready ->
      Game.onConnection()
      
  sendGameListRequest: () ->
    now.getGames()

  sendCreateGameRequest: (gameName, numberPlayers, playerName) ->
    now.createGame(gameName, numberPlayers, playerName)

  sendJoinGameRequest: (gameNumber, screenName) ->
    id = 0
    dicefaceSymbols = {"bracketL":-8,"bracketR":-7,"sqrt":-6,"power":-5,"multiply":-4,"divide":-3,"plus":-2,"minus":-1,"zero":0,"one":1,"two":2,"three":3,"four":4,"five":5,"six":6,"seven":7,"eight":8,"nine":9}
    # Emulate the server firing these events
    now.acceptPlayer(id, dicefaceSymbols)
    players = [{"index":Game.myPlayerId,"name":screenName},{"index":1,"name":"Richard Lionheart"}]
    globalDice = [0, 0, -1, -1, -3, 9, 9, 0, -3, 7, -2, 2, 5, 1, 2, 5, 3, 4, 4, 4, 1, -1, -4, -2]
    goalSetterId = Game.myPlayerId
    goalSeconds = 120 # Two minutes to set the goal
    now.receiveGoalTurn(players, globalDice, goalSetterId, goalSeconds)
    alert "Great, you joined a game! Now you must set the goal, #{screenName}"


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
