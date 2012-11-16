class GoalScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'goal.html'

  # {Number[]} An array of dicefaces. The resources used to form goal.
  resources: []

  # {Number} How many dice has the user currently put in the added-to-goal area
  numberInGoal: 0

  constructor: () ->

  ###*
   * Load the Goal Screen. This screen lets the player chosen as goal-setter 
   * select which dice are the goal.
   * @param {Json} json This gives the screen this json: 
   *               {resources: Number[] the diceface numbers that can be chosen to be the goal}
  ###
  init: (json) ->
    @resources = json.resources
    # We received the array of dice that we will use to form the goal.
    # This method takes in the array of dice numbers to displays them in the dom. 
    $("#notadded-goal").html(DiceFace.listToHtml(@resources, true))
    thisReference = this
    resourceList = $('#notadded-goal li')
    resourceList.bind 'click', (event) ->
      thisReference.addToGoal($(this).data('index'));
    $('#sendgoal').bind 'click', (event) ->
      Network.sendGoal(thisReference.createGoalArray())


  ###*
   * Return the goal array from the dice in the added-to-goal area
   * @return {Integer} Each element is an index to the original resources array
  ###
  createGoalArray: () ->
    goalArray = []
    for d in $('#added-goal li[data-index]')
      goalArray.push ($(d).data('index')) 
    return goalArray


  ###*
   * Move a dice from resources to the goal. 
   * @param {Number} index The (zero based) index of the resources array to move.
  ###
  addToGoal: (index) ->
    # Add the diceface to the dom and add a click listener that removes it when its clicked
    if(@numberInGoal < 6) # There is a maximum of six dice allowed
      @numberInGoal++
      diceFace = DiceFace.toHtml(@resources[index])
      html = "<li class='dice' data-index='" + index + "'><span>#{diceFace}<span></li>"
      thisReference = this
      $('#notadded-goal li[data-index='+index+']').remove()
      $(html).appendTo("#added-goal").bind 'click', (event) ->
        thisReference.removeFromGoal($(this).data('index'));

  ###*
   * Remove a dice from the goal and put it back to resources. 
   * @param  {Number} index The (zero based) index in the adding to goal list of dice to remove
  ###
  removeFromGoal: (index) ->
    # Remove the diceface to the dom and add a click listener that adds it when its clicked
    @numberInGoal--
    diceFace = DiceFace.toHtml(@resources[index])
    html = "<li class='dice' data-index='" + index + "'><span>#{diceFace}<span></li>"
    thisReference = this
    $('#added-goal li[data-index='+index+']').remove()
    $(html).appendTo("#notadded-goal").bind 'click', (event) ->
      thisReference.addToGoal($(this).data('index'));

 
  

