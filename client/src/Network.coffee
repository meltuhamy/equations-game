playerNo = -1

now.acceptPlayer = (number) -> #called by the server if player is accepted
  playerNo = number

now.ready ->
  now.addClient()

#now.joinGame ->
#  now.addClient