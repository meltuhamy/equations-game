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
    now.acceptPlayer(id, dicefaceSymbols)
    alert 'Great, you joined a game!'

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
