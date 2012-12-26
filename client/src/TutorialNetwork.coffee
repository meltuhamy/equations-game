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
    globalDice = [1, 2, 3, 0, -2, 1, -3, -4, -4, 1, 1, 2, 2, 5, 7, 9, 9, -1, -3, 2, 4, -1, 6, -2]
    goalSetterId = Game.myPlayerId
    goalSeconds = 120 # Two minutes to set the goal
    now.receiveGoalTurn(players, globalDice, goalSetterId, goalSeconds)
    ScreenSystem.renderScreen(Game.tutorialGoalScreenId, {globalDice: globalDice, timerDuration: goalSeconds})

  ###*
   * Sends the goal array to the server
   * @param  {Number[]} goalArray An array of indices to the global dice array.
  ###
  sendGoal: (goalArray) ->
    screen = currentScreen()
    if screen instanceof TutorialGoalScreen and screen.nextTargetIndex is screen.allowedIndices.length
      goalArray = screen.allowedIndices
      myunallocated = []
      allindices = [1..23]
      myunallocated.push i for i in allindices when not (i in screen.allowedIndices)
      state =
        unallocated: myunallocated
        required: []
        optional: []
        forbidden: []
        currentPlayer: 0 # Because it's the tutorial, let him play first.
        turnNumber: 1    # First turn
        possiblePlayers: []
        impossiblePlayers: []
        turnStartTime: Date.now()
        turnDuration: 120 
        playerScores: [0,0]
        readyForNextRound: []
      now.receiveGoalTurnEnd(goalArray)
      now.receiveState(state)


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
