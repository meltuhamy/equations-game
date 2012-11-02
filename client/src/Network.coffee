playerNo = -1
goal = undefined
state = undefined

now.acceptPlayer = (number) -> #called by the server if player is accepted
  playerNo = number

now.receiveState = (s) ->
  state = s

sendGoal = (goalArray) -> #When client clicks send goal on the gui, call this function
  now.receiveGoal(goalArray) #calls the server function receiveGoal, which parses it and stores it in the game object



now.ready ->
  now.addClient()

#now.joinGame ->
#  now.addClient