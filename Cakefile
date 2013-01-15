
# Load the user's config file and get the required names of programs
config = require('./config.js')
myCoffee = config.COFFEE
myStylus = config.STYLUS
myJnode  = config.JASMINE

# Debug mode is off by default
DEBUGMODE = off

# Load node's file system module
fs = require 'fs'

# Get the print method from node's sys module
{print} = require 'sys'

# Get the spawn method from node's sys module. We use win-spawn.js to use the equivalent if we're on windows.
{spawn} = require('./server/win-spawn.js')

###*
 * Compiles server code
 * @param  {Function} callback If provided, calls this once the code is compiled
###
server = (callback) ->
  # Spawn the CoffeeScript binary and give it these arguments:
  coffee = spawn myCoffee, ['-b', '-c', '-o', './', 'server/src/']

  # When there's an error, output it
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()

  # When  there's any output, output it
  coffee.stdout.on 'data', (data) ->
    print data.toString()

  # When the program exits, call the callback
  coffee.on 'exit', (code) ->
    if code is 0 then callback?() else console.error "\nThere was a problem with compiling the server code"

###*
 * Compiles client code
 * @param  {Function} callback If provided, calls this once the code is compiled
###
client = (callback) ->
  # Compile the stylus stuff 
  dostylus false, ->
    # Compile the client code. Here's the list of file names that we want to compile and concatenate.
    clientFileNames = ['Settings','Sound', 'DiceFace', 'ErrorManager', 'EquationBuilder', 'Game', 'Commentary', 'Network', 'TutorialNetwork', 'nowListener', 'Screen', 'Screen/LobbyScreen', 'Screen/JoinWaitScreen', 'Screen/GoalWaitScreen', 'Screen/GoalScreen', 'Screen/GameScreen', 'Screen/EndRoundScreen', 'Screen/EndGameScreen', 'Screen/TutorialLobbyScreen', 'Screen/TutorialGoalScreen', 'Screen/TutorialGameScreen', 'ScreenSystem', 'Tutorial', 'GlobalListener', 'main']
    options = [].concat(['-b', '--join', 'client/build/game.js', '--compile'], (clientFileNames.map (filename) -> 'client/src/' + filename + '.coffee'))
    
    # Call the coffeescript binary with options as arguments
    coffee = spawn myCoffee, options

    # When  there's any output, output it
    coffee.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
      print data.toString()

    # When we exit, call the callback if successful
    coffee.on 'exit', (code) ->
      callback?() if code is 0


###*
 * Compiles both client and server code.
###
build = (callback) ->
  server(client)

###*
 * Compiles the server and client code and runs the server
###
run = ->
  server ->
    client ->
      nodeArgs = ['server.js']

      # If we've turned on debug mode, then pass in an extra argument to node.
      if DEBUGMODE then nodeArgs.push 'debug'

      # Finally, run the node binary with the required arguments
      newNode = spawn 'node', nodeArgs

      # Output stuff if there's any output
      newNode.stderr.on 'data', (data) ->
        process.stderr.write data.toString()
      newNode.stdout.on 'data', (data) ->
        print data.toString()
    

###*
 * Compiles the server and client code and runs the server for debugging
###
debug = ->
  server ->
    client ->
      # Node arguments for debugging
      nodeArgs = ['--debug-brk','server.js']

      # If debug mode, then add another argument
      if DEBUGMODE then nodeArgs.push 'debug'

      # Run the node binary with required arguments
      newNode = spawn 'node', nodeArgs

      # Output any output from the binary
      newNode.stderr.on 'data', (data) ->
        process.stderr.write data.toString()
      newNode.stdout.on 'data', (data) ->
        print data.toString()

###*
 * Compiles the server and client code and run the tests
 * @param  {Function} callback If provided, calls this function when the code is compiled
###
tests = (callback) ->
  server -> 
    client -> 
      # Runs the node-jasmine binary with these params
      jnode = spawn myJnode, ['--coffee', '--color', 'spec/']

      # Output any output from the binary
      jnode.stderr.on 'data', (data) ->
        process.stderr.write data.toString()
      jnode.stdout.on 'data', (data) ->
        print data.toString()

      # When the program exits, call callback if it was successful
      jnode.on 'exit', (code) ->
        callback?() if code is 0
    
  

###*
 * Compiles the stylus files into css
 * @param  {Boolean}   watch    If specified, watches the scripts for changes
 * @param  {Function} callback  If provided, gets called when the files are compiled
###
dostylus = (watch, callback) ->
  # Run the stylus libraries with differnt params according to watch
  if watch? && watch
    stylus = spawn myStylus, ['-u', 'nib', '-w','-o', 'client/css/', 'client/css/stylus']
  else
    stylus = spawn myStylus, ['-u', 'nib', '-o', 'client/css/', 'client/css/stylus']

  # If the program does any output, output it here too.
  stylus.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  stylus.stdout.on 'data', (data) ->
    print data.toString()

  # When the program exits, call the callback if specified
  stylus.on 'exit', (code) ->
    callback?() if code is 0

###*
 * LINUX ONLY: Watches the client-side code for changes and recompiles when needed.
###
watch = () ->
  # Load and run the script
  watchScript = spawn 'sh', ['watchClient.sh', config.CAKE]

  # Do any output if the script does any.
  watchScript.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  watchScript.stdout.on 'data', (data) ->
    print data.toString()

###*
 * Sets up the node dependencies
 * @param  {Function} callback If provided, gets called when dependencies are set up.
###
setupNpmDependencies = (callback) ->
  # The list of dependencies for our project
  dependencies = ['install', 'coffee-script', 'express', 'socket.io', 'stylus', 'jasmine-node', 'node-inspector', 'nib', 'soda']

  # Nowjs doesnt work on windows, so only add it when not windows
  if require('os').type() isnt 'Windows_NT' then dependencies.push 'now'

  # Load and run npm with the dependencies as arguments
  npmInstaller = spawn 'npm', dependencies

  # If npm does any output, output it here too.
  npmInstaller.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  npmInstaller.stdout.on 'data', (data) ->
    print data.toString()

  # When npm exits, call callback if provided.
  npmInstaller.on 'exit', (code) ->
    callback?() if code is 0



##############################################################################
#   Cakefile Tasks (these show up when you type 'cake' in the project dir)   #
##############################################################################

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

option '-d', '--debug', 'Turns debug mode ON. (off by default)'

task 'run', 'Compile everything and run the server', (options) ->
  if options.debug? then DEBUGMODE = on
  run()

task 'debug', 'Run the server with debugging. Break on line 1', (options) ->
  if options.debug? then DEBUGMODE = on
  debug()

task 'test', 'Compile everything and run unit tests', ->
  tests()

task 'stylus', 'Compiles and watches styl to css', ->
  dostylus(true)

