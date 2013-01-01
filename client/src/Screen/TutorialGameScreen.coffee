###*
 * class TutorialGameScreen extends GameScreen
###
class TutorialGameScreen extends GameScreen
  firstClick: false
  drawAllocationMoveMenu: (clickedOn) ->
    super(clickedOn)
    if !@firstClick
      Tutorial.doStep()
      firstClick = true