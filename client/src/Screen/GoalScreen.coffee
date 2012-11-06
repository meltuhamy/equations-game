class GoalScreen extends Screen
  file: 'goal.html'
  constructor: () -> @file = @file

  ###*
   * Load the Goal Screen. This screen lets the player chosen as goal-setter 
   * select which dice are the goal.
   * @param {Json} json This gives the screen this json: 
   *               {resources: Number[] the diceface numbers that can be chosen to be the goal}
  ###
  init: (json) ->
    $('li').bind 'click', (event) =>
      console.log "inside-goal HELLO!!!"
 
  ###*
   * We reveived the array of dice that we will use to form the goal.
   * This method takes in the array of dice numbers to displays them in the dom. 
   * @param  {Number[]} unallocated  The unallocated array of dicefaces
  ###
  showResources: (unallocated)->
    $("#inside-goal").html(@diceFacesToHtml(unallocated))