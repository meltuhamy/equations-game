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

  allocate: ->
    @unallocated =  [DICEFACES.zero, DICEFACES.one]
    @required =  [DICEFACES.plus]
    @optional =  [DICEFACES.seven, DICEFACES.nine, DICEFACES.plus]
    @forbidden =  []

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


module.exports.Mats = Mats;


class Game
  mats: undefined
  constructor: ->
    @mats = new Mats()
    @mats.allocate()

module.exports.Game = Game;