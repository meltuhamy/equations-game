###*
 * class TutorialGameScreen extends GameScreen
###
class TutorialGameScreen extends GameScreen
  # {Boolean} Whether or not this was our first click on an alloc menu
  firstClick: false

  ###** @override ###
  drawAllocationMoveMenu: (clickedOn) ->
    super(clickedOn)

    # If this was our first click, then move forward in the tutorial.
    if !@firstClick
      Tutorial.doStep()
      firstClick = true