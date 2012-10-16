express = require("express")
server = express.createServer()
server.use(express.static(__dirname + "/client"))
server.listen 8080
console.log "Listening"

nowjs = require("now")
everyone = nowjs.initialize(server)


DiceFace = require './DiceFace.js'
DICEFACES = DiceFace.DICEFACES

game = new DiceFace.Game()

everyone.now.logStuff = (message) ->
  console.log message

everyone.now.moveUnallocatedToMat = (destinationMatType, unallocatedIndex) ->
  console.log "Previous game state: "
  console.log game
  game.mats.moveUnallocatedToMat(destinationMatType, unallocatedIndex)
  console.log "After game state: "
  console.log game