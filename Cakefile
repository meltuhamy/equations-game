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
    callback?() if code is 0



client = (callback) ->
  dostylus()
  fileNames = ['Network','main']
  options = [].concat(['-b', '--join', 'client/build/game.js', '--compile'], (fileNames.map (filename) -> 'client/src/' + filename + '.coffee'))
  coffee = spawn myCoffee, options
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

build = (callback) ->
  server(client)

run = ->
  server(client(->
    newNode = spawn 'node', ['server.js']
    newNode.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    newNode.stdout.on 'data', (data) ->
      print data.toString()
  ))

debug = ->
  server(client(->
    newNode = spawn 'node', ['--debug-brk','server.js']
    newNode.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    newNode.stdout.on 'data', (data) ->
      print data.toString()
  ))


tests = (callback) ->
  build()
  jnode = spawn myJnode, ['--coffee', '--color', 'spec/']
  jnode.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  jnode.stdout.on 'data', (data) ->
    print data.toString()
  jnode.on 'exit', (code) ->
    callback?() if code is 0



dostylus = (watch) ->
  if watch? && watch
    stylus = spawn myStylus, ['-u', 'nib', '-w','-o', 'client/css/', 'client/css/stylus']
  else
    stylus = spawn myStylus, ['-u', 'nib', '-o', 'client/css/', 'client/css/stylus']
  stylus.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  stylus.stdout.on 'data', (data) ->
    print data.toString()




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

