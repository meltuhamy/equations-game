###*
 * class TutorialLobbyScreen extends LobbyScreen
###
class TutorialLobbyScreen extends LobbyScreen
  init: (json) ->
    window.tutorial = true
    window.network = new TutorialNetwork()
    roomlistroomlist = [{"nowjsname":"game0","gameName":"Join me!","gameNumber":0,"playerCount":1,"playerLimit":2,"started":false}]
    @onUpdatedGameList(roomlistroomlist)
    Tutorial.init()
    Tutorial.doStep()