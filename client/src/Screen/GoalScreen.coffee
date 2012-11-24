#getData = (element, key, value) -> $(element).attr("data-#{key}", value);


class GoalScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'goal.html'

  # {Number[]} An array of dicefaces. The resources used to form goal.
  resources: []

  # {Number} How many dice has the user currently put in the added-to-goal area
  numberInGoal: 0

  # {Number} How many dots/brackets are there
  numberDots: 0

  # sea blue, green, yellow, red, teal, magenta, orange, grey, toxic green, black, white
  #bracketColors: ['#0CF0CF', '#2EA700', '#C2DD00', '#C94800', '#00C9C9', '#C900A9', '#E4B625', '#8F8F8F', '#00FF14', '#000000', '#FFFFFF']


  # 
  #bracketColors: ['#4F9172', '#3E7A5E', '#69B391', '#59B88C', '#238E68']





  # {Number} Tells us whether we are in the middle of adding brackets. 0 = No, 
  # 1 = We have already clicked to add a left bracket
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
   * [dotListener description]
   * @return {[type]} [description]
  ###
  dotListener: (element) ->
    if($(element).attr('data-bracket') is 'none') then @addBracket(element) else @removeBracket(element)
  


  getNextBracketColor: (bracketsCounter) ->
    brightnessPercent = 80-((bracketsCounter*2)/@numberDots)*50
    return "hsl(120, 50%, #{brightnessPercent}%)"

    
    


  ###*
   * Add brackets. We have clicked on a dot and so change it to a bracket.
   * @param  {DomElement} element The bracket element we clicked on 
  ###
  addBracket: (element) ->
    thisReference = this
    if(@bracketClicks == 0)
      # When we are clicking to add the left bracket
      @leftBracketIndex = $(element).index('li.dot')
      if(@leftBracketIndex < @numberDots-1)
        # Change the dot to a left bracket
        $(element).attr('data-bracket','left')

        # Give the newly added left bracket a color 
        #$(element).css('color', '#FFFFFF')

        # Now say that the next click will be for adding a left bracket
        @bracketClicks = (@bracketClicks+1)%2

        # Now we may need to add an extra dot at the very start, if left bracket we add is at the start
        if(@leftBracketIndex == 0 && @numberInGoal > 1)
          html = "<li class='dot' data-bracket='none'><span></span></li>"
          @numberDots++
          @leftBracketIndex++
          $(html).prependTo("#added-goal").bind 'click', (event) ->
            thisReference.dotListener(this)

    else if(@bracketClicks == 1)
      # When we are clicking to add the right bracket
      rightBracketIndex = $(element).index('li.dot')
      if(@leftBracketIndex < rightBracketIndex)
        # Change the dot to a right bracket
        $(element).attr('data-bracket','right')

        # Now say that the next click will be for adding a right bracket
        @bracketClicks = (@bracketClicks+1)%2


        @pairUpBrackets()

        # Now we may need to add an extra dot at the end, when we add a right bracket at the very end
        if(rightBracketIndex == @numberDots-1 && @numberInGoal > 1)
          html = "<li class='dot' data-bracket='none'><span></span></li>"
          @numberDots++
          $(html).appendTo("#added-goal").bind 'click', (event) ->
            thisReference.dotListener(this)

  ###*
   * [pairUpBrackets description]
  ###
  pairUpBrackets: () ->
    ref = this
    bracketsCounter = 0
    $('li.dot').each (index, element) ->
      if($(element).attr('data-bracket') is 'left')
        counter = 1
        matchingRightBracket = undefined
        $(element).nextAll('li.dot').each (index, dot) ->
          if($(dot).attr('data-bracket') is 'left') then counter++
          if($(dot).attr('data-bracket') is 'right') then counter--
          if(counter == 0)
            matchingRightBracket = dot
            return false

        # For the given pair, give them the game color
        leftBracketColor = ref.getNextBracketColor(bracketsCounter)
        $(element).css('color', leftBracketColor)
        $(matchingRightBracket).css('color', leftBracketColor)

        # For the given pair, assign them a pairing identiefer using data-bracketid attribute
        $(element).attr('data-bracketid', ref.bracketsCounter)
        $(matchingRightBracket).attr('data-bracketid', ref.bracketsCounter)
        bracketsCounter += 1
      






  ###*
   * Remove brackets. We have clicked on a dot and so change 
   * @param  {DomElement} element The bracket element we clicked on
  ###
  removeBracket: (element) ->
    thisReference = this
    if(@bracketClicks == 0)
      # If we clicked on a left bracket
      if($(element).attr('data-bracket') is 'left')
        nextDots = $(element).nextAll('li.dot')
        counter = 1
        matchingRightBracket = undefined
        for dot in nextDots
          if($(dot).attr('data-bracket') is 'left') then counter++
          if($(dot).attr('data-bracket') is 'right') then counter--
          if(counter == 0)
            matchingRightBracket = dot
            break
        # Remove the left bracket 
        $(element).attr('data-bracket','none')
        $(matchingRightBracket).attr('data-bracket','none')
        @cleanUpBrackets()
      # If we clicked on a right bracket
      else if($(element).attr('data-bracket') is 'right') 
        prevDots = $(element).prevAll('li.dot')
        counter = 1
        matchingLeftBracket = undefined
        for dot in prevDots
          if($(dot).attr('data-bracket') is 'left') then counter--
          if($(dot).attr('data-bracket') is 'right') then counter++
          if(counter == 0)
            matchingLeftBracket = dot
            break
        # Remove the left bracket 
        $(element).attr('data-bracket','none')
        $(matchingLeftBracket).attr('data-bracket','none')
        @cleanUpBrackets()

 





  ###*
   * Move a dice from resources to the goal.
   * Add the diceface to the dom and add a click listener that removes it when its clicked 
   * @param {Number} index The (zero based) index of the resources array to move.
  ###
  addDiceToGoal: (index) ->
    
    # There is a maximum of six dice allowed
    # Only allow dice to be added when we are not in the middle of adding brackets
    if(@numberInGoal < 6 && @bracketClicks == 0) 
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
        thisReference.removeDiceFromGoal($(this).data('index'));
      $(html2).appendTo("#added-goal").bind 'click', (event) ->
        thisReference.dotListener(this)

  ###*
   * Remove a dice from the goal and put it back to resources. 
   * Remove the diceface to the dom and add a click listener that adds it when its clicked
   * @param  {Number} index The (zero based) index in the adding to goal list of dice to remove
  ###
  removeDiceFromGoal: (index) ->
    if(@bracketClicks == 0)
      @numberInGoal--
      diceFace = DiceFace.toHtml(@resources[index])
      html = "<li class='dice' data-index='" + index + "'><span>#{diceFace}<span></li>"
      thisReference = this
      $('#added-goal li.dice[data-index='+index+']').remove()
      @cleanUpBrackets()
      @pairUpBrackets()
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

      if $(d).attr('data-bracket') is 'none' then $(d).css('color', '')

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


