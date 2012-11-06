class GoalScreen extends Screen
  file: 'goal.html'
  constructor: () ->

  ###*
   * Load the Goal Screen. This screen lets the player chosen as goal-setter 
   * select which dice are the goal.
   * @param {Json} json This gives the screen this json: 
   *               {resources: Number[] the diceface numbers that can be chosen to be the goal}
  ###
  init: (json) ->
    @showResources(json.resources)
    lis = $('#inside-goal li')
    thisReference = this
    lis.bind 'click', (event) ->
      console.log "inside-goal HELLO!!!"
      thisReference.addToGoal($('#inside-goal li').index(this));
 
  ###*
   * We reveived the array of dice that we will use to form the goal.
   * This method takes in the array of dice numbers to displays them in the dom. 
   * @param  {Number[]} resources  The resources array of dicefaces
  ###
  showResources: (resources)->
    $("#inside-goal").html(DiceFace.listToHtml(resources))


  ###*
   * Move a dice from resources to the goal. 
   * @param {Number} index The (zero based) index of the resources array to move.
  ###
  addToGoal: (index) ->
    console.log index
    $('#outside-goal').append($("#inside-goal li:nth-child(#{index+1})")) # nth-child is *not* zero-indexed
    $('#inside-goal').remove("li:nth-child(#{index+1})")