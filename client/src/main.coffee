###*
 * main
###
$(document).ready(->
  Game.onDocumentReady()
  ScreenSystem.loadAllScreens(->network.initialise())
)

currentScreen = -> ScreenSystem.getCurrentScreen()