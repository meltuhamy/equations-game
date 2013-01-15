###*
 * class TutorialLobbyScreen extends LobbyScreen
###
class TutorialLobbyScreen extends LobbyScreen
  init: (json) ->
    window.tutorial = true
    window.network = new TutorialNetwork() # Very important. Tells the client we want to use our tutorial-mode network.
    roomlistroomlist = [{"nowjsname":"game0","gameName":"Join me!","gameNumber":0,"playerCount":1,"playerLimit":2,"started":false}]
    @onUpdatedGameList(roomlistroomlist)
    Tutorial.init()
    Tutorial.doStep()