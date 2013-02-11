config = require('./config.js')
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

if config.inCloudEditor? and config.inCloudEditor
  console.log "In C9 environment. port: #{process.env.PORT}; host: #{process.env.IP}"
  server.listen(process.env.PORT, process.env.IP)
else
  server.listen(8080)
console.log "Listening"

isDebug = 'debug' in process.argv
if isDebug then console.warn "DEBUG MODE IS ON"

module.exports.app = app
module.exports.server = server
module.exports.nowjs = nowjs
module.exports.debugmode = isDebug