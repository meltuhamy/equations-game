express = require("express")
http = require('http')
nowjs = require("now")

app = express()
server = http.createServer(app)
app.use(express.static(__dirname + "/client"))

server.listen(8080)
console.log "Listening"

everyone = nowjs.initialize(server)


DiceFace = require './DiceFace.js'
DICEFACES = DiceFace.DICEFACES

game = new DiceFace.Game([])

everyone.now.addClient = () ->
  game.addClient(this.user.clientId)


everyone.now.logStuff = (message) ->
  console.log message

###
everyone.now.moveUnallocatedToMat = (destinationMatType, unallocatedIndex) ->
  console.log "Previous game state: "
  console.log game
  game.mats.moveUnallocatedToMat(destinationMatType, unallocatedIndex)
###

  #everyone.now.draw(this.user.clientId, message);

everyone.now.testFunc = () ->
  console.log(this.user.addClient)
