# Change this to wherever your coffee file is. (change the username below)
config = require('./config.js')

myCoffee = config.COFFEE
myStylus = config.STYLUS
myJnode  = config.JASMINE


fs = require 'fs'

{print} = require 'sys'
{spawn} = require('./server/win-spawn.js')

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
    clientFileNames = ['Settings', 'DiceFace', 'ErrorManager', 'EquationBuilder', 'Game', 'Network', 'TutorialNetwork', 'nowListener', 'Screen', 'Screen/LobbyScreen', 'Screen/JoinWaitScreen', 'Screen/GoalWaitScreen', 'Screen/GoalScreen', 'Screen/GameScreen', 'Screen/EndRoundScreen', 'Screen/EndGameScreen', 'Screen/TutorialLobbyScreen', 'Screen/TutorialGoalScreen', 'Screen/TutorialGameScreen', 'ScreenSystem', 'Tutorial','main']
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

      javaselenium = spawn 'lsof', [config.SELENIUM]
      javaselenium.stderr.on 'data', (data) ->
        console.log data.toString()
      javaselenium.stdout.on 'data', (data) ->
        console.log ""
      javaselenium.on 'exit', (code) ->
        if(code is 0)
          console.log "Selenium appears to be running."
          jnode = spawn myJnode, ['--coffee', '--color', 'spec/']
          jnode.stderr.on 'data', (data) ->
            process.stderr.write data.toString()
          jnode.stdout.on 'data', (data) ->
            print data.toString()
          jnode.on 'exit', (code) ->
            callback?() if code is 0
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

watch = () ->
  watchScript = spawn 'sh', ['watchClient.sh', config.CAKE]
  watchScript.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  watchScript.stdout.on 'data', (data) ->
    print data.toString()

setupNpmDependencies = (callback) ->
  dependencies = ['install', 'coffee-script', 'express', 'socket.io', 'stylus', 'jasmine-node', 'node-inspector', 'nib', 'soda']
  if require('os').type() isnt 'Windows_NT' then dependencies.push 'now'
  npmInstaller = spawn 'npm', dependencies
  npmInstaller.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  npmInstaller.stdout.on 'data', (data) ->
    print data.toString()
  npmInstaller.on 'exit', (code) ->
    callback?() if code is 0




task 'setup', 'Set up dependencies', ->
  setupNpmDependencies(->
    console.log "\n**********************\n-> Node.js dependencies are now set up."
    console.log "-> Make sure you have copied and configured your own config.js: "
    console.log "    cp config.js.sample config.js"
    console.log "-> Modify config.js to work with your machine and user."
    console.log "\n-> Downloaded selenium modify its location in config.js"
    console.log "    Go to http://goo.gl/NYxbW\n"
    console.log "-> If in labs, edit your .cshrc file. Add the following aliases"
    console.log '    alias coffee "~/node_modules/coffee-script/bin/coffee"'
    console.log '    alias cake "~/node_modules/coffee-script/bin/cake"'
    console.log '    alias node-inspector "~/node_modules/node-inspector/bin/inspector.js --web-port=8081"'
    console.log "\n-> To test that everything is working, run the tests"
    console.log "    cake test"

  )

task 'build', 'Compile everything', ->
  build()

task 'client', 'Compile client code including .styl', ->
  client()

task 'watch', 'Compile client when changes made in client/src/*', ->
  watch()

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

