###*
 * Global key press listeners
###
$(document).on "keyup", (e) ->
  if ScreenSystem.currentScreen? then ScreenSystem.currentScreen.onKeyup(e)