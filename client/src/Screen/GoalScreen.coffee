class GoalScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'goal.html'

  # {Number[]} An array of indices to the resources array.
  goalArray: []

  # {Number[]} An array of dicefaces. The resources used to form goal.
  resources: []


  inGoalBitmap: []
  resourceDomElements: []
  goalDomElements: []

  constructor: () ->

  ###*
   * Load the Goal Screen. This screen lets the player chosen as goal-setter 
   * select which dice are the goal.
   * @param {Json} json This gives the screen this json: 
   *               {resources: Number[] the diceface numbers that can be chosen to be the goal}
  ###
  init: (json) ->

    @resources = json.resources
    @showResources()

    @inGoalBitmap = (0 for num in @resources)
    @resourceDomElements = $('#outside-goal li')
    @goalDomElements = $('#inside-goal li')

    $("#inside-goal li").hide()

    thisReference = this
    resourceList = $('#inside-goal li')
    
    resourceList.bind 'click', (event) ->
      thisReference.addToGoal($('#inside-goal li').index(this));

    $('#sendgoal').bind 'click', (event) ->
      Network.sendGoal(goalArray)

 
  ###*
   * We reveived the array of dice that we will use to form the goal.
   * This method takes in the array of dice numbers to displays them in the dom. 
  ###
  showResources: () ->
    $("#inside-goal").html(DiceFace.listToHtml(@resources))
    $("#outside-goal").html(DiceFace.listToHtml(@resources))


  ###*
   * Move a dice from resources to the goal. 
   * @param {Number} index The (zero based) index of the resources array to move.
  ###
  addToGoal: (index) ->
    @inGoalBitmap[index] = 1
    @resourceDomElements.get(index).hide()
    @goalDomElements.get(index).show()

