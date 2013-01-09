###*
 * Global key press listeners
###
$(document).on "keyup", (e) ->
  switch e.which
    when 80 then network.pauseTurnTimer() # P key
    when 82 then network.resumeTurnTimer() # R key
    when 83 then network.skipTurn() # S key