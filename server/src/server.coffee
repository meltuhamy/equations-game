{app, server, nowjs, debugmode} = require './ServerListener.js'

{DiceFace}  = require './DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols

{ErrorManager}  = require './ErrorManager.js'
ERRORCODES = ErrorManager.codes

{Game} = require './Game.js'
{Player} = require './Player.js'
{GamesManager} = require './GamesManager.js'
{Settings} = require './Settings.js'

Settings.DEBUG = debugmode

everyone = nowjs.initialize(server)
everyone.on 'disconnect', ->
  console.log "DISCONNECT: #{this.user.clientId}"

  if(this.now.gameNumber?)
    clientId = this.user.clientId
    gameNumber = this.now.gameNumber
    {game, group} = getThisGameGroup(gameNumber)
    groupReference = group.now
    console.log "leaveGame now method called."
    playerIndex = game.removeClient(clientId)
    game.nextTurn( ->
      groupReference.receiveMoveTimeUp()
      groupReference.receiveState(game.state))
    group.now.receivePlayerDisconnect(playerIndex)
    group.now.receiveState(game.state)

everyone.on 'connect', ->
  console.log "CONNECT: #{this.user.clientId}"
  gamesManager.cleanGames()

gamesManager = new GamesManager()
if Settings.DEBUG
  gamesManager.newGame('Test Game', 2, 2)
  gamesManager.newGame('Some Game', 3, 2)


###*
 * Returns a pair {game,group} specifying the game and group for the given gameNumber
 * @param  {[type]} gameNumber [description]
 * @return {Json} with game: {Game} the Game object for the game
 *                     group: {String} the string id nowjs uses for nowjs groups
###
getThisGameGroup = (gameNumber) =>
  game = gamesManager.getGame(gameNumber)
  group = nowjs.getGroup(game.nowJsGroupName)
  return {game: game, group: group}
    

everyone.now.createGame = (name, numPlayers, playerName, numRounds) ->
  gameNumber = gamesManager.newGame(name, numPlayers, numRounds)
  this.now.addClient(gameNumber, playerName)
  everyone.now.getGames()


everyone.now.addClient = (gameNumber, playerName) -> #called by client when connected
  {game, group} = getThisGameGroup(gameNumber)
  
  # Check that the person isn't already in a group
  notInRoom = !this.now.gameNumber?

  if(notInRoom && !game.isFull() && !game.started)
    # add the player to the nowjs group
    group.addUser(this.user.clientId)

    # place the gameNumber in the client pocket
    this.now.gameNumber = gameNumber

    # add the player to the game, tell him he was accepted and give him his playerId (i.e. index) for the game
    this.now.acceptPlayer(game.addClient(this.user.clientId, playerName), DICEFACESYMBOLS, ERRORCODES)

    # tell everyone about the new gamesList state
    everyone.now.getGames()

    # Now see if the game is full after adding him (i.e see if is the last player)
    # If it is, then tell everyone in this game that its the goal setting turn. 
    if(game.isFull() && !game.started)
      game.goalStart(-> group.now.receiveGoalTurn(game.players, game.globalDice, game.getGoalSetterPlayerId(), Settings.goalSeconds)) # TODO: add timer callback
      group.now.receiveGoalTurn(game.players, game.globalDice, game.getGoalSetterPlayerId(), Settings.goalSeconds)
  else
    # else the game is already full, so tell him - tough luck



everyone.now.getGames = ->
  gamesList = gamesManager.getGamesListJson()
  this.now.receiveGameList(gamesList)




# client telling the server about the goal
# this is when the goal setter sends his goal. 
# if the goal is valid, we tell everyone what the goal is.
everyone.now.receiveGoal = (goalArray) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  groupReference = group.now
  if !(this.user.clientId == game.playerSocketIds[game.getGoalSetterPlayerId()])
    throw "Unauthorised goal setter"
  try
    game.setGoal(goalArray,  ->
      groupReference.receiveMoveTimeUp()
      groupReference.receiveState(game.state)
    )
    group.now.receiveGoalTurnEnd(game.goalArray)
    group.now.receiveState(game.state)
  catch e #catches when parser returns error for goal
    this.now.receiveError(e)



# put this in everyone's pocket. Server calls this when a player took too long.
everyone.now.moveTimeUp = (nextPlayerSocId) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  group.now.receiveState(game.state)
  this.now.receiveMoveTimeUp()
  

# client telling the server that he wants to move a dice from unallocated to required
# index = index to the unallocated array
everyone.now.moveToRequired = (index) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  groupReference = group.now
  try
    globalDiceBeingMoved = game.state.unallocated[index]
    game.moveToRequired(index, this.user.clientId, ->
      groupReference.receiveMoveTimeUp()
      groupReference.receiveState(game.state)
    )
    group.now.receiveMoveToRequired(game.getPlayerIdBySocket(this.user.clientId), globalDiceBeingMoved)
    group.now.receiveState(game.state)
    
  catch e
    this.now.badMove(e)
    console.log e

# client telling the server that he wants to move a dice from unallocated to optional
# index = index to the unallocated array
everyone.now.moveToOptional = (index) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  groupReference = group.now
  try
    globalDiceBeingMoved = game.state.unallocated[index]
    game.moveToOptional(index, this.user.clientId, ->
      groupReference.receiveMoveTimeUp()
      groupReference.receiveState(game.state)
    )
    group.now.receiveMoveToOptional(game.getPlayerIdBySocket(this.user.clientId), globalDiceBeingMoved)
    group.now.receiveState(game.state)
    
  catch e
    this.now.badMove(e)
    console.log e

# client telling the server that he wants to move a dice to forbidden
everyone.now.moveToForbidden = (index) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  groupReference = group.now
  try
    globalDiceBeingMoved = game.state.unallocated[index]
    game.moveToForbidden(index, this.user.clientId, ->
      groupReference.receiveMoveTimeUp()
      groupReference.receiveState(game.state)
    )
    group.now.receiveMoveToForbidden(game.getPlayerIdBySocket(this.user.clientId), globalDiceBeingMoved)
    group.now.receiveState(game.state)
    
  catch e
    this.now.badMove(e)
    console.log e
  

# client telling the server that he wants to make a now challenge
everyone.now.nowChallengeRequest = () ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  groupReference = group.now
  game.nowChallenge(this.user.clientId, ->
    groupReference.receiveMoveTimeUp()
    groupReference.receiveState(game.state)
    group.now.receiveChallengeSolutionsTurn()
  )
  group.now.receiveNowChallengeDecideTurn(game.getPlayerIdBySocket(this.user.clientId))
  group.now.receiveState(game.state)

# client telling the server that he wants to make a never challenge
everyone.now.neverChallengeRequest = () ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  groupReference = group.now
  game.neverChallenge(this.user.clientId, ->
    groupReference.receiveMoveTimeUp()
    groupReference.receiveState(game.state)
    group.now.receiveChallengeSolutionsTurn()
  )
  group.now.receiveNeverChallengeDecideTurn(game.getPlayerIdBySocket(this.user.clientId))
  group.now.receiveState(game.state)


# client telling the server that he has made a decision about the challenge
everyone.now.challengeDecision = (agree) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  groupReference = group.now
  callback = ->
    groupReference.receiveMoveTimeUp()
    groupReference.receiveState(game.state)
    if game.isGameOver()
      group.now.receiveChallengeRoundEndTurn(
        game.getSubmittedSolutions(),
        game.getAnswerExists(),
        game.getRoundChallengePoints(),
        game.getRoundDecisionPoints(),
        game.getRoundSolutionPoints()
      )
    else
      group.now.receiveChallengeRoundEndTurn(
        game.getSubmittedSolutions(),
        game.getAnswerExists(),
        game.getRoundChallengePoints(),
        game.getRoundDecisionPoints(),
        game.getRoundSolutionPoints()
      )
  try
    if((agree && game.challengeModeNow) || (!agree && !game.challengeModeNow))
      game.submitPossible(this.user.clientId, callback)
    else if((agree && !game.challengeModeNow) || (!agree && game.challengeModeNow))
      game.submitImpossible(this.user.clientId, callback)
    group.now.receiveState(game.state)
    if(game.allDecisionsMade())
      if(game.state.possiblePlayers.length == 0)
        if game.isGameOver()
          group.now.receiveChallengeRoundEndTurn(
            game.getSubmittedSolutions(),
            game.getAnswerExists(),
            game.getRoundChallengePoints(),
            game.getRoundDecisionPoints(),
            game.getRoundSolutionPoints()
          )
        else
          group.now.receiveChallengeRoundEndTurn(
            game.getSubmittedSolutions(),
            game.getAnswerExists(),
            game.getRoundChallengePoints(),
            game.getRoundDecisionPoints(),
            game.getRoundSolutionPoints()
          )
      else
        group.now.receiveChallengeSolutionsTurn()

  catch e
    this.now.badMove(e)
    console.log e


# client telling the server that he wants to submit a solution
everyone.now.challengeSolution = (answer) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  try
    game.submitSolution(this.user.clientId, answer)
    group.now.receiveState(game.state)
    if(game.allSolutionsSent())
      if game.isGameOver()
        group.now.receiveChallengeRoundEndTurn(
          game.getSubmittedSolutions(),
          game.getAnswerExists(),
          game.getRoundChallengePoints(),
          game.getRoundDecisionPoints(),
          game.getRoundSolutionPoints()
        )
      else
        group.now.receiveChallengeRoundEndTurn(
          game.getSubmittedSolutions(),
          game.getAnswerExists(),
          game.getRoundChallengePoints(),
          game.getRoundDecisionPoints(),
          game.getRoundSolutionPoints()
        )
  catch e
    this.now.receiveError(e)
    console.log e


# client telling the server that he is ready for next round
everyone.now.nextRoundReady = ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  game.readyForNextRound(this.user.clientId)
  if(game.allNextRoundReady())
    group.now.receiveNextRoundAllReady()
    game.nextRound()
    group.now.receiveState(game.state)
    group.now.receiveGoalTurn(game.players, game.globalDice, game.getGoalSetterPlayerId(), Settings.goalSeconds)
  
clientLeaveGame = (clientId, gameNumber) ->
  
