###*
 * main
###
$(document).ready ->
  Sound.preload ->
    Game.onDocumentReady()
    ScreenSystem.loadAllScreens(->network.initialise())


currentScreen = -> ScreenSystem.getCurrentScreen()