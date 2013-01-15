###*
 * class TutorialGoalScreen extends GoalScreen
###
class TutorialGoalScreen extends GoalScreen
  allowedIndices: undefined
  nextTargetIndex: 0

  ###** @override ###
  constructor: ->
    @allowedIndices = [0, 4, 19] # The allowed indices (match to '1+2')
    super()

  ###** @override
  * Wrap over parent's method, but allow only specific dice to be added to the goal.
  ###
  addDiceToGoal: (index) ->
    # This forces the user to click on only what we tell them to clock.
    if 0<=@nextTargetIndex<@allowedIndices.length and index is @allowedIndices[@nextTargetIndex]
      super index
      @nextTargetIndex++
      Tutorial.doStep()
    else 
      console.log "Can't press that..."

  ###** @override ###
  removeDiceFromGoal: (index) ->
    console.log "Can't do that in tutorial."
