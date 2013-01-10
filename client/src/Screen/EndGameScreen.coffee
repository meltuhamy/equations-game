###*
 * class EndGameScreen extends EndRoundScreen
 *
 * For now, this just extends EndRoundScreen because there's not enough time to have a proper screen.
###
class EndGameScreen extends EndRoundScreen
  # {String} The filename of the html file to load the screen.
  file: 'endgame.html'
  init: (json) ->
    super(json)
    $('h2#end-round-title').html('That was the final round. Game over!')
    $('#ready-round-cntr').remove()
    now.core.socketio.socket.disconnect()

  addReadyButtonListener: () ->
