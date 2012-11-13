$(document).ready(->
  Game.initialise()
  ScreenSystem.loadAllScreens(->Network.initialise())
)