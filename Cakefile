# Change this to wherever your coffee file is.
myCoffee = 'coffee'

fs = require 'fs'

{print} = require 'sys'
spawn = require('child_process').spawn

server = (callback) ->
  coffee = spawn myCoffee, ['-b', '-c', '-o', 'server/', 'server/src/']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

client = (callback) ->
  fileNames = ['main']
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
  

open = (callback) ->
  spawn 'open', ['client/index.html']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0



task 'build', 'Compile client and server code', ->
  build()

task 'client', 'Compile client code', ->
  client()

task 'server', 'Compile server code', ->
  server()

task 'run', 'Compile client and server code, run the server, open index.html', ->
  

task 'test', 'Compile client, server and test code, run the server, open the test html', ->
  tests()

task 'open', 'Open index.html', ->
  open()