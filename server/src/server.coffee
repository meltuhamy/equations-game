express = require("express")
http = require('http')
nowjs = require("now")

app = express()
server = http.createServer(app)
app.use(express.static(__dirname + "/client"))

app.get('/views/:viewName', (req, res) ->
  console.log("REQUEST MADE #{req.params.viewName}")
  res.sendfile(__dirname + "/views/#{req.params.viewName}")
)

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
 
 everyone.now.receiveGoal = (goalArray) -> #recieves the goal array from client
  #need to validate goal array at some point
  try
    game.setGoal(goalArray)
  catch e
    this.now.badGoal("Bad goal:" + e)
  


  

everyone.now.logStuff = (message) ->
  console.log message

everyone.now.testFunc = () ->
  console.log(this.user.addClient)

###
flatten = (node) ->
  str = ""
  if node.children then str += "["
  str+= " "
  str += DICEFACES.getString node.token
  if node.children
    str+=" "
    str += flatten(child) for child in node.children
  str+= " "
  if node.children then str +="]"
  str

prettyPrint = (node) -> console.log flatten(node)
module.exports.prettyPrint = prettyPrint
###