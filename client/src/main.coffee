###*
 * main
###
$.fn.qtip.zindex = 1000; # Needed to do this because the modal windows go under tooltips.
$(document).ready ->
  Sound.preload ->
    Game.onDocumentReady()
    ScreenSystem.loadAllScreens(->network.initialise())


currentScreen = -> ScreenSystem.getCurrentScreen()