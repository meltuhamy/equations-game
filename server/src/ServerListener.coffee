express = require("express")
http = require('http')
nowjs = require("now")

app = express()
server = http.createServer(app)
app.use(express.static(__dirname + "/client"))

app.get('/views/:viewName', (req, res) ->
  res.sendfile(__dirname + "/views/#{req.params.viewName}")
)

server.listen(8080)
console.log "Listening"

module.exports.app = app
module.exports.server = server
module.exports.nowjs = nowjs