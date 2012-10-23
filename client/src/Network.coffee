playerNo = 0

now.acceptPlayer = (number) ->
  playerNo = number

now.ready ->
  now.addClient()

#now.joinGame ->
#  now.addClient