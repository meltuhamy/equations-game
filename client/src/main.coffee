$(document).ready(->
  screensystem = new ScreenSystem("#container")
  homeScreenId = screensystem.addScreen(new HomeScreen())
  goalScreenId = screensystem.addScreen(new GoalScreen())
  console.log goalScreenId
  console.log homeScreenId
  screensystem.loadAllScreens(->screensystem.renderScreen(goalScreenId))

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