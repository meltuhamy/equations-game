{DiceFace} = require './DiceFace.js'
DICEFACESYMBOLS = DiceFace.symbols
class Settings
  @DEBUG = off
  # The global dice used in debug mode
  @DEBUGDICE = [1, DICEFACESYMBOLS.plus, 2, DICEFACESYMBOLS.minus, 3, 4, 5, 6, 7, 8, 9, 0, DICEFACESYMBOLS.divide, 9, 9, 1, 2, 9, 4, 5, DICEFACESYMBOLS.minus, DICEFACESYMBOLS.plus, 2, 4]
  @turnSeconds = 30
  @challengeDecisionTurnSeconds = 40
  @submitTurnSeconds = 40
  @goalSeconds = 30
  
  


module.exports.Settings = Settings