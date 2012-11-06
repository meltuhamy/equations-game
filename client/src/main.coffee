$(document).ready(->
  Game.initialise()
  ScreenSystem.loadAllScreens(->Network.initialise())
)


###
  $('#unallocated ul li').click(->
    $(this).toggleClass('glow')
    $('.mat').toggleClass('glow')
  )
###
###
$('#inside-goal li').ready(->
  $('#inside-goal li').click(->
    alert "clicked on li with index #{this.index()}"
    ui.moveToGoal(this.index())
  )
)
###