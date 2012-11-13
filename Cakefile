# Change this to wherever your coffee file is. (change the username below)
config = require('./config.js')

myCoffee = config.COFFEE
myStylus = config.STYLUS
myJnode  = config.JASMINE


fs = require 'fs'

{print} = require 'sys'
spawn = require('child_process').spawn

server = (callback) ->
  coffee = spawn myCoffee, ['-b', '-c', '-o', './', 'server/src/']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?()


client = (callback) ->
  dostylus(false, ->
    clientFileNames = ['Settings', 'Game','DiceFace', 'Network', 'Screen', 'Screen/GoalScreen', 'Screen/HomeScreen', 'ScreenSystem', 'main']
    options = [].concat(['-b', '--join', 'client/build/game.js', '--compile'], (clientFileNames.map (filename) -> 'client/src/' + filename + '.coffee'))
    coffee = spawn myCoffee, options
    coffee.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
      print data.toString()
    coffee.on 'exit', (code) ->
      callback?() if code is 0
  )


build = (callback) ->
  server(client)

run = ->
  server( ->
    client(->
      newNode = spawn 'node', ['server.js']
      newNode.stderr.on 'data', (data) ->
        process.stderr.write data.toString()
      newNode.stdout.on 'data', (data) ->
        print data.toString()
    )
  )

debug = ->
  server( ->
    client(->
    newNode = spawn 'node', ['--debug-brk','server.js']
    newNode.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    newNode.stdout.on 'data', (data) ->
      print data.toString()
    )
  )


tests = (callback) ->
  server( -> 
    client(-> 
      javaselenium = spawn 'java', ['-jar', config.SELENIUM]
      javaselenium.stderr.on 'data', (data) ->
        process.stderr.write "\nSELENIUM: "+ data.toString()
      javaselenium.stdout.on 'data', (data) ->
        #print data.toString()
      newNode = spawn 'node', ['server.js']
      newNode.stderr.on 'data', (data) ->
        process.stderr.write "\nSERVER: " + data.toString()
      newNode.stdout.on 'data', (data) ->
        print "\nSERVER: " + data.toString()
      console.log "Selenium running.\n Starting jasmine tests in 6 seconds"
      setTimeout( -> 
        jnode = spawn myJnode, ['--coffee', '--color', 'spec/']
        jnode.stderr.on 'data', (data) ->
          process.stderr.write "JASMINE: " +  data.toString()
        jnode.stdout.on 'data', (data) ->
          print "JASMINE: " + data.toString()
        jnode.on 'exit', (code) ->
          newNode.kill('SIGTERM')
          javaselenium.kill('SIGTERM')
          callback?() if code is 0
      , 6000)
    )
  )




dostylus = (watch, callback) ->
  if watch? && watch
    stylus = spawn myStylus, ['-u', 'nib', '-w','-o', 'client/css/', 'client/css/stylus']
  else
    stylus = spawn myStylus, ['-u', 'nib', '-o', 'client/css/', 'client/css/stylus']
  stylus.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  stylus.stdout.on 'data', (data) ->
    print data.toString()
  stylus.on 'exit', (code) ->
    callback?() if code is 0




task 'build', 'Compile everything', ->
  build()

task 'client', 'Compile client code including .styl', ->
  client()

task 'server', 'Compile server code', ->
  server()

task 'run', 'Compile everything and run the server', ->
  run()

task 'debug', 'Run the server with debugging. Break on line 1', ->
  debug()

task 'test', 'Compile everything and run unit tests', ->
  tests()

task 'stylus', 'Compiles and watches styl to css', ->
  dostylus(true)

