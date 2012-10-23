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

everyone.now.addClient = () -> #called by client when connected
  try
    pNo = game.addClient(this.user.clientId)
    this.now.acceptPlayer(pNo)
  catch e
    console.warn e
  


everyone.now.logStuff = (message) ->
  console.log message

everyone.now.testFunc = () ->
  console.log(this.user.addClient)
