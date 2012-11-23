#getData = (element, key, value) -> $(element).attr("data-#{key}", value);


class GoalScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'goal.html'

  # {Number[]} An array of dicefaces. The resources used to form goal.
  resources: []

  # {Number} How many dice has the user currently put in the added-to-goal area
  numberInGoal: 0

  numberDots: 0


  bracketClicks: 0
  leftBracketIndex: 0


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
    for d in $('#added-goal li.dice[data-index]')
      if($(d).hasClass('dice'))
        goalArray.push ($(d).data('index')) 
      else if($(d).hasClass('dot'))
        if($(d).attr('bracket') is 'left')
          goalArray.push (24)
        else if($(d).attr('bracket') is 'right')
          goalArray.push (25)
    return goalArray


  

  ###*
   * Add brackets to
  ###
  addBracket: (element) ->
    thisReference = this
    if(@bracketClicks == 0)
      @leftBracketIndex = $(element).index('li.dot')
      if(@leftBracketIndex < @numberDots-1)
        $(element).attr('data-bracket','left')
        @bracketClicks = (@bracketClicks+1)%2
        if(@leftBracketIndex == 0 && @numberInGoal > 1)
          html = "<li class='dot' data-bracket='none'><span></span></li>"
          @numberDots++
          @leftBracketIndex++
          $(html).prependTo("#added-goal").bind 'click', (event) ->
            thisReference.dotListener(this)
    else if(@bracketClicks == 1)
      rightBracketIndex = $(element).index('li.dot')
      if(@leftBracketIndex < rightBracketIndex)
        $(element).attr('data-bracket','right')
        @bracketClicks = (@bracketClicks+1)%2
        if(rightBracketIndex == @numberDots-1 && @numberInGoal > 1)
          html = "<li class='dot' data-bracket='none'><span></span></li>"
          @numberDots++
          $(html).appendTo("#added-goal").bind 'click', (event) ->
            thisReference.dotListener(this)

  ###*
   * [dotListener description]
   * @return {[type]} [description]
  ###
  dotListener: (element) ->
    if($(element).attr('data-bracket') is 'none') then @addBracket(element) else console.log "Remove bracket"






  ###*
   * Move a dice from resources to the goal. 
   * @param {Number} index The (zero based) index of the resources array to move.
  ###
  addDiceToGoal: (index) ->
    # Add the diceface to the dom and add a click listener that removes it when its clicked
    if(@numberInGoal < 6) # There is a maximum of six dice allowed
      thisReference = this

      # If it's the first dice we just added, then we need to add the leftmost brackets dot
      if(@numberInGoal == 0) 
        @numberDots++
        html = "<li class='dot' data-bracket='none'><span></span></li>"
        $(html).appendTo("#added-goal").bind 'click', (event) ->
          thisReference.dotListener(this)

      @numberInGoal++
      @numberDots++
      diceFace = DiceFace.toHtml(@resources[index])
      html = "<li class='dice' data-index='" + index + "'><span>#{diceFace}<span></li>"
      html2 = "<li class='dot' data-bracket='none'><span></span></li>"
      $('#notadded-goal li.dice[data-index='+index+']').remove()
      @cleanUpBrackets()

      if($('li.dot:nth-last-child(2)').attr('data-bracket') is 'right')
        @numberDots--
        $('li.dot:last-child').remove()

      $(html).appendTo("#added-goal").bind 'click', (event) ->
        thisReference.removeFromGoal($(this).data('index'));
      $(html2).appendTo("#added-goal").bind 'click', (event) ->
        thisReference.dotListener(this)

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
    $('#added-goal li.dice[data-index='+index+']').remove()
    @cleanUpBrackets()
    $(html).appendTo("#notadded-goal").bind 'click', (event) ->
      thisReference.addDiceToGoal($(this).data('index'));


  cleanUpBrackets: () ->
    thisReference = this
    for d in $('#added-goal li')
      twoDotsCase = ($(d).prev().attr('data-bracket') is 'none') and ($(d).attr('data-bracket') is 'none')
      leftBrkDotCase = (($(d).prev().attr('data-bracket') is 'left') and ($(d).attr('data-bracket') is 'none'))
      dotRightBrkCase = (($(d).prev().attr('data-bracket') is 'none') and ($(d).attr('data-bracket') is 'right'))
      leftBkrRightBrkCase1 = (($(d).prev().attr('data-bracket') is 'left') and ($(d).attr('data-bracket') is 'right'))
      leftBkrRightBrkCase2 = (($(d).prev().attr('data-bracket') is 'right') and ($(d).attr('data-bracket') is 'left'))

      if (twoDotsCase || leftBrkDotCase || dotRightBrkCase || leftBkrRightBrkCase1 || leftBkrRightBrkCase2)
        # Adjust the left dot accordingly (since we always delete the right ... see below)
        if(leftBkrRightBrkCase1)
          $(d).prev().attr('data-bracket', 'none')
        else if(leftBkrRightBrkCase2)
          $(d).prev().attr('data-bracket', 'none')
        else if(leftBrkDotCase)
          $(d).prev().attr('data-bracket', 'left')
        else if(dotRightBrkCase)
          $(d).prev().attr('data-bracket', 'right')

        # Special case for when there is just one dot left
        if(@numberDots == 2)
          $(d).prev().remove()
          @numberDots--

        # Always remove the right dot/bracket
        @numberDots--
        $(d).remove()

        # Now try and clean up again
        @cleanUpBrackets()
          
          


    ### previousDot = $('li.dice[data-index='+index+']').prev()
    nextDot     = $('li.dice[data-index='+index+']').next()
    $(nextDot).remove()###
    # Remove the dice from the goal
    ###if($(previousDot).data('bracket') is 'left' and $(nextDot).data('bracket') is 'right')
      $(previousDot).attr('data-bracket', 'none')
      $(previousDot).remove()
      @numberDots--
    else
      $(previousDot).attr('data-bracket', nextDot.data('bracket'))###
    ###if(@numberInGoal == 0)
      $('#added-goal li.dot.first').remove()
      @numberDots--###
  

