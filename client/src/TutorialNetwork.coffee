###*
 * class TutorialNetwork extends Network
 * Pretends to know what the server does and just does client calls
###
class TutorialNetwork extends Network
  ###** @override ###
  initialise: ->
    @moveToRequiredOrdering = [1]
    Game.onConnection()

  ###** @override ###      
  sendGameListRequest: () ->
    console.warn("game list request in tutorial")

  ###** @override ###
  sendCreateGameRequest: (gameName, numberPlayers, playerName) ->
    now.createGame(gameName, numberPlayers, playerName)

  ###** @override ###
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

  ###** @override ###
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
      ScreenSystem.renderScreen(Game.tutorialGameScreenId)
      now.receiveState(state)

  ###** @override ###
  moveToRequired: (index) ->
    console.warn("move to required in tutorial")

  ###** @override ###
  moveToOptional: (index) ->
    console.warn("move to optional in tutorial")

  ###** @override ###
  moveToForbidden: (index) ->
    console.warn("move to forbidden in tutorial")

  ###** @override ###
  sendNowChallengeRequest: () ->
    console.warn("now challenge in tutorial")

  ###** @override ###
  sendNeverChallengeRequest: () ->
    console.warn("never challenge in tutorial")

  ###** @override ###
  sendChallengeDecision: (agree) ->
    console.warn("agreed with challenge in tutorial")

  ###** @override ###
  sendChallengeSolution: (answer) ->
    console.warn("sent answer in tutorial")

  ###** @override ###
  sendNextRoundReady: () ->
    console.warn("next round ready in tutorial")
