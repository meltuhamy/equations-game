{app, server, nowjs} = require './ServerListener.js'

{DiceFace}  = require './DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols

{Game} = require './Game.js'
{Player} = require './Player.js'
{GamesManager} = require './GamesManager.js'

everyone = nowjs.initialize(server)

gamesManager = new GamesManager()
gamesManager.newGame('Test Game', 2)
gamesManager.newGame('Some Game', 3)
gamesManager.newGame('The Game', 2)
gamesManager.newGame('One Game', 5)


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
    


everyone.now.createGame = (name, numPlayers) ->
  gameNumber = gamesManager.newGame(name, numPlayers)
  this.now.addClient(gameNumber)
  everyone.now.getGames()


everyone.now.addClient = (gameNumber) -> #called by client when connected
  {game, group} = getThisGameGroup(gameNumber)
  
  # Check that the person isn't already in a group
  notInRoom = !this.now.gameNumber?

  if(notInRoom && !game.isFull())
    # add the player to the nowjs group
    group.addUser(this.user.clientId)

    # place the gameNumber in the client pocket
    this.now.gameNumber = gameNumber

    # add the player to the game, tell him he was accepted and give him his playerId (i.e. index) for the game
    this.now.acceptPlayer(game.addClient(this.user.clientId), DICEFACESYMBOLS)

    # tell everyone about the new gamesList state
    everyone.now.getGames()

    # Now see if the game is full after adding him (i.e see if is the last player)
    # If it is, then tell everyone in this game that its the goal setting turn. 
    if(game.isFull())
      game.goalStart() # TODO: add timer callback
      group.now.receiveGoalTurn(game.players, game.globalDice, game.getGoalSetterPlayerId())
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
    console.log e.message
    this.now.badGoal(e.message)


# put this in everyone's pocket. Server calls this when a player took too long.
everyone.now.moveTimeUp = (nextPlayerSocId) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  group.now.receiveState(game.state)
  this.now.receiveMoveTimeUp()
  

# client telling the server that he wants to move a dice to required
everyone.now.moveToRequired = (index) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  groupReference = group.now
  try
    game.moveToRequired(index, this.user.clientId, ->
      groupReference.receiveMoveTimeUp()
      groupReference.receiveState(game.state)
    )
    group.now.receiveState(game.state)
  catch e
    this.now.badMove(e)
    console.log e

# client telling the server that he wants to move a dice to optional
everyone.now.moveToOptional = (index) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  groupReference = group.now
  try
    game.moveToOptional(index, this.user.clientId, ->
      groupReference.receiveMoveTimeUp()
      groupReference.receiveState(game.state)
    )
    group.now.receiveState(game.state)
  catch e
    this.now.badMove(e)
    console.log e

# client telling the server that he wants to move a dice to forbidden
everyone.now.moveToForbidden = (index) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  groupReference = group.now
  try
    game.moveToForbidden(index, this.user.clientId, ->
      groupReference.receiveMoveTimeUp()
      groupReference.receiveState(game.state)
    )
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
      group.now.receiveChallengeSolutionsTurn()

  catch e
    this.now.badMove(e)
    console.log e


# client telling the server that he wants to submit a solution
everyone.now.challengeSolution = (answer) ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  try
    game.submitSolution(this.user.clientId, answer)
    if(game.allSolutionsSent())
      group.now.receiveChallengeRoundEndTurn(
        game.getSubmittedSolutions(),
        game.getAnswerExists(),
        game.getRoundChallengePoints(),
        game.getRoundDecisionPoints(),
        game.getRoundSolutionPoints()
      )
  catch e
    this.now.badMove(e.message)
    console.log e


# client telling the server that he is ready for next round
everyone.now.nextRoundReady = ->
  {game, group} = getThisGameGroup(this.now.gameNumber)
  game.readyForNextRound(this.user.clientId)
  if(game.allNextRoundReady())
    group.now.receiveNextRoundAllReady()
    game.nextRound()
    group.now.receiveState(game.state)
    group.now.receiveGoalTurn(game.players, game.globalDice, game.getGoalSetterPlayerId())


