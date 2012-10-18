class DICEFACES
  @zero        : 0
  @one         : 1
  @two         : 2
  @three       : 3
  @four        : 4
  @five        : 5
  @six         : 6
  @seven       : 7
  @eight       : 8
  @nine        : 9
  @plus        : 10
  @minus       : 11
module.exports.DICEFACES = DICEFACES;

numOps = 2

###
class MATTYPES
  @forbidden        : 0
  @required         : 1
  @optional         : 2
module.exports.MATTYPES = MATTYPES;

class Mats
  unallocated: []
  required: []
  optional: []
  forbidden: []


  moveUnallocatedToMat: (destinationMatType, unallocatedIndex) ->
    #Put it in the destinationMatType mat
    theMat = @getMatArrayByType(destinationMatType)
    theMat.push(@unallocated[unallocatedIndex])

    #Remove from unallocated: slice the array into 2 parts, missing out the element at unallocatedIndex, then join back together
    @unallocated = @unallocated[0...unallocatedIndex].concat(@unallocated[unallocatedIndex+1...@unallocated.length])

  getMatArrayByType: (type) ->
    switch type
      when MATTYPES.forbidden then @forbidden
      when MATTYPES.required then @required
      when MATTYPES.optional then @optional 
###

#module.exports.Mats = Mats;


class Game
  #mats: undefined
  goal: []
  players: []
  state: {
    unallocated: []
    required: []
    optional: []
    forbidden: []
    currentPlayer: 0
  }
  #turn
  constructor: (players) ->
    @players = players
    @allocate()
    console.log @state.unallocated

  allocate: ->
    ops = 0
    for x in [1..24]
      rand = Math.random()
      console.log rand
      if rand < 2/3
        rand = Math.floor(Math.random() * 10)
      else
        rand = Math.floor(Math.random() * numOps) + 10
        ops++
      @state.unallocated.push(rand)
    console.log ops
    if (ops < 2) || (ops > 21)
      @state.unallocated = []
      @allocate()

  setGoal: (diceTypes) ->
    @goal = diceTypes

#  addEveryoneToGame: () ->
 #   everyone.now.ready()
    #everyone.now.joinGame()

  addClient: (clientid) ->
    @players.push(new Player(clientid))
    console.log @players

module.exports.Game = Game;

class Player
  id: 0
  constructor: (id) ->
    @id = id

module.exports.Player = Player;