###*
 * class EndGameScreen extends EndRoundScreen
 *
 * For now, this just extends EndRoundScreen because there's not enough time to have a proper screen.
###
class EndGameScreen extends EndRoundScreen
  # {String} The filename of the html file to load the screen.
  file: 'endgame.html'

  addReadyButtonListener: () ->
