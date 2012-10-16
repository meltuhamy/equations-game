# Change this to wherever your coffee file is. (change the username below)
myCoffee = '/homes/me1810/node_modules/coffee-script/bin/coffee'

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
  fileNames = ['main', 'Dice']
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

tests = (callback) ->
  server(client(->
    coffee = spawn myCoffee, ['-b', '-c', '-o', 'test/spec/', 'test/coffeespec/']
    coffee.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
      print data.toString()
    coffee.on 'exit', (code) ->
      if code is 0 then spawn 'open', ['test/index.html']
  ))


task 'build', 'Compile client and server code', ->
  build()

task 'client', 'Compile client code', ->
  client()

task 'server', 'Compile server code', ->
  server()

task 'run', 'Compile client, server code, run the server', ->
  run()

task 'test', 'Compile client, server, test code + run the server', ->
  tests()