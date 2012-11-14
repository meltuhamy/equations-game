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
      checkedListeningOnce = false
      javaselenium = spawn 'lsof', [config.SELENIUM]
      javaselenium.stderr.on 'data', (data) ->
        console.log data.toString()
      javaselenium.stdout.on 'data', (data) ->
        console.log ""
      javaselenium.on 'exit', (code) ->
        if(code is 0)
          console.log "Selenium appears to be running."
          newNode = spawn 'node', ['server.js']
          newNode.stderr.on 'data', (data) ->
            process.stderr.write "\nSERVER: " + data.toString()
          newNode.stdout.on 'data', (data) ->
            print "\nSERVER: " + data.toString()
            if(!checkedListeningOnce && data.toString()=="Listening\n")
              checkedListeningOnce = true
              console.log "Starting Jasmine Tests"
              setTimeout( -> 
                jnode = spawn myJnode, ['--coffee', '--color', 'spec/']
                jnode.stderr.on 'data', (data) ->
                  process.stderr.write data.toString()
                jnode.stdout.on 'data', (data) ->
                  print data.toString()
                jnode.on 'exit', (code) ->
                  newNode.kill('SIGTERM')
                  callback?() if code is 0
              , 2000)
        else
          console.error "\n\nSelenium is not running. You need to run it in a *new* terminal window. You need only do this once.\nOpen a new terminal window and run the command below:"
          console.error "java -jar #{config.SELENIUM}\n"
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

setupNpmDependencies = (callback) ->
  dependencies = ['install', 'coffee-script', 'express', 'socket.io', 'now', 'stylus', 'jasmine-node', 'node-inspector', 'nib', 'soda']
  npmInstaller = spawn 'npm', dependencies
  npmInstaller.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  npmInstaller.stdout.on 'data', (data) ->
    print data.toString()
  npmInstaller.on 'exit', (code) ->
    callback?() if code is 0


task 'setup', 'Set up dependencies', ->
  setupNpmDependencies(->
    console.log "\n-> Node.js dependencies are now set up."
    console.log "-> Make sure you have copied and configured your own config.js: "
    console.log "    cp config.js.sample config.js; #Then modify config.js to work with your machine."
    console.log "\n-> Make sure you have downloaded selenium server and have placed it's path in config.js"
    console.log "    Go to http://goo.gl/NYxbW\n"
  )

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

