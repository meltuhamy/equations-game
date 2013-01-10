###*
 * Global key press listeners
###
$(document).on "keyup", (e) ->
  ScreenSystem.currentScreen.onKeyup(e)