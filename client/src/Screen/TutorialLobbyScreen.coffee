###*
 * class TutorialLobbyScreen extends LobbyScreen
###
class TutorialLobbyScreen extends LobbyScreen
  init: (json) ->
    window.network = new TutorialNetwork()
    roomlistroomlist = [{"nowjsname":"game0","gameName":"Test Game","gameNumber":0,"playerCount":0,"playerLimit":2,"started":false},{"nowjsname":"game1","gameName":"Some Game","gameNumber":1,"playerCount":0,"playerLimit":3,"started":false}]
    @onUpdatedGameList(roomlistroomlist)