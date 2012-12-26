###*
 * class TutorialGoalScreen extends GoalScreen
###
class TutorialGoalScreen extends GoalScreen
  allowedIndices: undefined
  nextTargetIndex: 0

  constructor: ->
    @allowedIndices = [0, 4, 19] # The allowed indices (match to '1+2')
    super()

  # Wrap over parent's method, but allow only specific dice to be added to the goal.
  addDiceToGoal: (index) ->
    if 0<=@nextTargetIndex<@allowedIndices.length and index is @allowedIndices[@nextTargetIndex]
      super index
      @nextTargetIndex++
      Tutorial.doStep()
    else 
      console.log "Can't press that..."

  removeDiceFromGoal: (index) ->
    console.log "Can't do that in tutorial."
