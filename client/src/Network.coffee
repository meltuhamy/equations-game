playerId = -1
goal = undefined
state = undefined 
game = undefined

now.acceptPlayer = (id) -> #called by the server if player is accepted
  playerId = id

now.receiveState = (s) ->
  state = s

now.receiveStartGame = (diceJson, players, firstTurnPlayerIndex) ->
  game.diceJson = diceJson
  game.players = players
  game.goingFirst = firstTurnPlayerIndex


#now.joinGame ->
#  now.addClient

sendGoal = (goalArray) -> #When client clicks send goal on the gui, call this function
  now.receiveGoal(goalArray) #calls the server function receiveGoal, which parses it and stores it in the game object

#
now.badGoal = (message) ->
  console.log message


now.ready ->
  now.addClient()
  game = new Game()







