express = require("express")
server = express.createServer()
server.use(express.static(__dirname + "/client"))
server.listen 8080
console.log "Listening"

nowjs = require("now")
everyone = nowjs.initialize(server)
everyone.now.logStuff = (msg) ->
  console.log msg
