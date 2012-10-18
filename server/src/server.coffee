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

everyone.now.addClient = () ->
  game.addClient(this.user.clientId)


everyone.now.logStuff = (message) ->
  console.log message

everyone.now.moveUnallocatedToMat = (destinationMatType, unallocatedIndex) ->
  game.mats.moveUnallocatedToMat(destinationMatType, unallocatedIndex)


  #everyone.now.draw(this.user.clientId, message);

 everyone.now.testFunc = () ->
  console.log(this.user.addClient)
