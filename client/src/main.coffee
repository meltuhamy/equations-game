###*
 * main
###
$(document).ready(->
  Game.onDocumentReady()
  ScreenSystem.loadAllScreens(->Network.initialise())
)