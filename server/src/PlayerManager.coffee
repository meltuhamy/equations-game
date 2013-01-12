{Player} = require './Player.js'
{Settings} = require './Settings.js'
class PlayerManager

  # {Player[]} An array of players who have joined the game
  players: []

  # {Number} The nowjs sockets for players. These match up index-by-index with players array
  playerSocketIds: []

  # {Number} The maximum number of players allow in the game.
  playerLimit: 2

  # {Number} An index to players array. Player who sets the goal (takes the goal setting turn)
  goalSetter: undefined

  # {Number} the index of the player array for the challenger
  challenger: undefined

  # {Number []} An array of player indices that have submitted solutions during a challenge
  submittedSolutions: []

  # {Number []} An array of player indices that have submitted correct answers during a challenge
  rightAnswers: []

  constructor: ->
    @players = []
    @playerSocketIds = []
    @playerLimit = 2
    @goalSetter = undefined
    @challenger = undefined
    @submittedSolutions = []
    @rightAnswers = []

  # Convert a player id to a socketid and vica versa
  getPlayerIdBySocket: (socket) -> @playerSocketIds.indexOf(socket)
  getPlayerSocketById: (id) -> @playerSocketIds[id]

  ###*
   * Returns whether or not the game is full
   * @return {Boolean} If true, then the game is full
  ###
  full: () -> @players.length is @playerLimit

  ###*
   * Adds a new player with playername and socket id.
   * @param {String} playerName The name of the player
   * @param {String} clientid   The socket id of the client
   * @return {Number} The player index id of the player that was added
  ###
  add: (clientid, playerName) ->
    newPlayerIndex = @players.length
    @players.push(new Player(newPlayerIndex, playerName))
    @playerSocketIds.push(clientid)
    return newPlayerIndex

  ###*
   * Removes the player with the given clientid.
   * @param  {String} clientid The player with the this client id will be removed
   * @return {Number}          Returns the player id index of the player that was removed
  ###
  remove: (clientid) ->
    index = @getPlayerIdBySocket(clientid)
    @players.splice(index, 1)
    @playerSocketIds.splice(index,1)
    @submittedSolutions.splice(index, 1)
    @rightAnswers.splice(index,1)
    return index

  numPlayers: -> @players.length

  ###*
   * Get the index of the player who moves the first dice from unallocated
   * @return {[Integer} An index to the players array
  ###
  getFirstTurnPlayerId: () -> 
    if !@goalSetter? then @getGoalSetterPlayerId()
    return @goalSetter+1%@numPlayers()

  # If we want to get his socket id instead of the player array index
  getFirstTurnPlayerSocketId: () -> @getPlayerSocketById(@getFirstTurnPlayerId())

  ###*
   * Return the index of the player who will set the goal
   * @return {[Integer} An index to the players array
  ###
  getGoalSetterPlayerId: () ->
    if !@goalSetter?
      @setGoalSetterPlayerId()
    return @goalSetter

  ###*
   * Gets a random player id (index).
   * @param  {Number[]} exceptions If this is provided, the "random" player number will not include anything in this array.
   * @return {Number}            A player id (index)
  ###
  randomPlayerId: (exceptions) ->
    e = [].concat(exceptions)
    numPlayers = @numPlayers()
    newNumber = Math.floor(Math.random() * numPlayers)
    newNumber = Math.floor(Math.random() * numPlayers) while newNumber in e
    return newNumber

  ###*
   * Sets the goal setter to forceId. If no parameter given, chooses random goalSetter.
   * @param {Number} forceId If provided, will give the goal setter this id, otherwise a random.
  ###
  setGoalSetterPlayerId: (forceId) ->
    if(!forceId?)
      #set a random goalSetter
      if Settings.DEBUG
        @goalSetter = 0
      else
        exceptions = if @goalSetter? then @goalSetter else []
        @goalSetter = @randomPlayerId(exceptions)
    else
      @goalSetter = forceId

  ###*
   * See if this player is allowed to make this move.
   * @param  {[type]} socketId The nowjs socket id of the player.
   * @return {[type]}          Return True if it is this player's turn to move 
  ###
  authenticateMove: (socketId, playerId) -> socketId is @getPlayerSocketById(playerId)

  validateChallenge: (socketId, playerId) ->
    numPlayers = @numPlayers()
    prevPlayerId = ((playerId-1)+numPlayers)%numPlayers
    socketId isnt @getPlayerSocketById(prevPlayerId)

module.exports.PlayerManager = PlayerManager
