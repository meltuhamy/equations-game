{DiceFace} = require './DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols
class Settings
  @DEBUG = off
  # The global dice used in debug mode
  @DEBUGDICE = [1, DICEFACESYMBOLS.plus, 2, DICEFACESYMBOLS.minus, 3, 4, 5, 6, 7, 8, 9, 0, DICEFACESYMBOLS.divide, 9, 9, 1, 2, 9, 4, 5, DICEFACESYMBOLS.minus, DICEFACESYMBOLS.plus, 2, 4]
  # The number of seconds for allocation turns
  @turnSeconds = 99
  # The number of seconds for challenge decision turns
  @challengeDecisionTurnSeconds = 40
  # The number of seconds for challenge solution turns
  @submitTurnSeconds = 99
  # The number of seconds for the player to set the goal
  @goalSeconds = 99
  
  


module.exports.Settings = Settings