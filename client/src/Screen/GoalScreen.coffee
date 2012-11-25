
class GoalScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'goal.html'

  # {Number[]} An array of dicefaces. The resources used to form goal.
  resources: []

  # {EquationBuilder} Used to build equations in the goal screen.
  equationBuilder: undefined

  
  constructor: () ->


  ###*
   * Load the Goal Screen. This screen lets the player chosen as goal-setter 
   * select which dice are the goal.
   * @param {Json} json This gives the screen this json: 
   *               {resources: Number[] the diceface numbers that can be chosen to be the goal}
  ###
  init: (json) ->
    @equationBuilder = new EquationBuilder('#added-goal')
    @resources = json.resources
    # We received the array of dice that we will use to form the goal.
    # This method takes in the array of dice numbers to displays them in the dom. 
    $("#notadded-goal").html(DiceFace.listToHtml(@resources, true))
    thisReference = this
    resourceList = $('#notadded-goal li.dice')
    resourceList.bind 'click', (event) ->
      thisReference.addDiceToGoal($(this).data('index'));
    $('#sendgoal').bind 'click', (event) ->
      Network.sendGoal(thisReference.createGoalArray())


  ###*
   * Return the goal array from the dice in the added-to-goal area
   * @return {Integer} Each element is an index to the original resources array
  ###
  createGoalArray: () ->
    goalArray = []
    for d in $('#added-goal li')
      if($(d).hasClass('dice'))
        goalArray.push ($(d).data('index')) 
      else if($(d).hasClass('dot'))
        console.log "this is a dot"
        if($(d).attr('data-bracket') is 'left')
          goalArray.push (-1)
        else if($(d).attr('data-bracket') is 'right')
          goalArray.push (-2)
    return goalArray


  


  ###*
   * Move a dice from resources to the goal.
   * Add the diceface to the dom and add a click listener that removes it when its clicked 
   * @param {Number} index The (zero based) index of the resources array to move.
  ###
  addDiceToGoal: (index) ->

    # There is a maximum of six dice allowed
    # Only allow dice to be added when we are not in the middle of adding brackets
    if(@equationBuilder.getNumberOfDice() < 6 && @equationBuilder.hasCompletedBrackets()) 
      thisReference = this

      diceFace = DiceFace.toHtml(@resources[index])
      html = "<li class='dice' data-index='" + index + "'><span>#{diceFace}<span></li>"
      
      # Remove the dice from the top
      $('#notadded-goal li.dice[data-index='+index+']').remove()

      # Add it to the bottom
      $(@equationBuilder.addDiceToEnd(html)).bind 'click', (event) ->
        thisReference.removeDiceFromGoal($(this).data('index'));


  ###*
   * Remove a dice from the goal and put it back to resources. 
   * Remove the diceface to the dom and add a click listener that adds it when its clicked
   * @param  {Number} index The (zero based) index in the adding to goal list of dice to remove
  ###
  removeDiceFromGoal: (index) ->
    # Try to remove the die from the equation builder container.
    removedElement = @equationBuilder.removeDiceByIndex(index)
    if(removedElement isnt false)
      # Add the dice back to the top
      thisReference = this   
      $(removedElement).appendTo("#notadded-goal").bind 'click', (event) ->
          thisReference.addDiceToGoal($(this).data('index'));



  


  