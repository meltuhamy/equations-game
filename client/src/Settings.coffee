###*
 * class Settings
###
class Settings
  @containerId: "container"

###*
 * Global key press listeners
###
$(document).on "keyup", (e) ->
  if e.which is 80 # === p
    network.pauseTurnTimer()
  if e.which is 82 # === r
    network.resumeTurnTimer()
