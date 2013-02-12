express = require("express")
http = require('http')
nowjs = require("now")

###########################################################################
#           This file is where we listen for HTTP requests etc.           #
###########################################################################

app = express()
server = http.createServer(app)
app.use(express.static(__dirname + "/client"))

app.get('/views/:viewName', (req, res) ->
  res.sendfile(__dirname + "/views/#{req.params.viewName}")
)

port = if process.env.PORT? then process.env.PORT else '8080'
ip = if process.env.IP then process.env.IP else '127.0.0.1'
server.listen(port, ip)
console.log("Listening on #{ip}:#{port}")

isDebug = 'debug' in process.argv
if isDebug then console.warn "DEBUG MODE IS ON"

module.exports.app = app
module.exports.server = server
module.exports.nowjs = nowjs
module.exports.debugmode = isDebug