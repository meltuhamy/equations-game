###*
 * main
###
$(document).ready(->
  Game.onDocumentReady()
  ScreenSystem.loadAllScreens(->Network.initialise())
)

currentScreen = -> ScreenSystem.getCurrentScreen()