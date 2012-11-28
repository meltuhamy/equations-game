
class EquationBuilder

  # {Number} How many dice has the user currently put in the added-to-goal area
  numberInGoal: 0

  # {Number} How many dots/brackets are there
  numberDots: 0

  # {Number} Tells us whether we are in the middle of adding brackets. 0 = No, 
  # 1 = We have already clicked to add a left bracket
  bracketClicks: 0

  # {Number} This is the index from the list of dots of the left bracket waiting to be completed 
  leftBracketIndex: 0

  # {Number} The jquery selector of the container where the equation is being built
  containerSelector: ''


  constructor: (@containerSelector) ->


  ###*
   * Add a dice to the end
   * @param {String} html The html for the element
   * @return {DomElement} The dice that we added
  ###
  addDiceToEnd: (html) ->
    # If it's the first dice we just added, then we need to add the leftmost brackets dot
    if(@numberInGoal == 0) 
      @addDot(true, @containerSelector)
    else if($(@containerSelector + ' li.dot:nth-last-child(2)').attr('data-bracket') is 'right')
      # If there was a ")." before it then change it to ")"
      @numberDots--
      $(@containerSelector + ' li.dot:last-child').remove()

    # Add a dice and dot in pairs
    theDice = $(html).appendTo(@containerSelector)
    @addDot(true, @containerSelector)

    # Then adjust the counters to say we added a new dice and dot
    @numberInGoal++
    @cleanUpBrackets()
    return theDice

  ###*
   * Remove a dice from the container
   * @param  {Number} index        The index of the brackets from the list of dice
   * @return {Boolean|DomElement}  The element if it got removed else returns false.
  ###
  removeDiceByIndex: (index) ->
    if(@hasCompletedBrackets())
      @numberInGoal--
      deletedElement = $(@containerSelector + ' li.dice[data-index='+index+']').clone()
      $(@containerSelector + ' li.dice[data-index='+index+']').remove()
      @cleanUpBrackets()
      return deletedElement
    else
      return false # If we can't delete the dice because we haven't completed brackets
      

  ###*
   * See whether we are in the middle of adding brackets
   * @return {Boolean} True iff we added a left bracket but didn't add corresponding right bracket.
  ###
  hasCompletedBrackets: () -> @bracketClicks == 0

  # How many dice are in the container.
  getNumberOfDice: () -> @numberInGoal


  getIndicesToGlobalDice: () ->
    result = []
    for d in $(@containerSelector + ' li')
      if($(d).hasClass('dice'))
        result.push (parseInt($(d).data('index'))) 
      else if($(d).hasClass('dot'))
        if($(d).attr('data-bracket') is 'left')
          result.push (-1)
        else if($(d).attr('data-bracket') is 'right')
          result.push (-2)
    return result



  ###*
   * Adds the a dot to the dom before or after an element. It adds the dotlistener click handler.
   * @param  {boolean} appendPrepend If true, appends to element. False prepends to element.
   * @param  {String} element The selector of the element to append/prepend to.
  ###
  addDot: (appendPrepend, element) -> 
    @numberDots++
    theHtml = "<li class='dot' data-bracket='none'><span></span></li>"
    thisReference = this
    # Either add a dot to the beginning or the end of element, then add the listener
    if(appendPrepend)
      $(theHtml).appendTo(element).bind 'click', (event) ->
        thisReference.dotListener(this)
    else
      $(theHtml).prependTo(element).bind 'click', (event) ->
        thisReference.dotListener(this)

  ###*
   * What to do when we click on a dot. This is called when we click on a dot/bracket.
  ###
  dotListener: (element) ->
    # If it's a normal dot then change it to a bracket. If it's a bracket then we may need to delete a bracket pair.
    if($(element).attr('data-bracket') is 'none') then @addBracket(element) else @removeBracket(element)


  ###*
   * Add brackets. We have clicked on a dot and so change it to a bracket.
   * @param  {DomElement} element The bracket element we clicked on 
  ###
  addBracket: (element) ->
    thisReference = this
    if(@bracketClicks == 0)
      # When we are clicking to add the left bracket
      @leftBracketIndex = $(element).index(@containerSelector + ' li.dot')
      if(@leftBracketIndex < @numberDots-1)
        # Change the dot to a left bracket
        $(element).attr('data-bracket','left')

        # Give the newly added left bracket a color 
        #$(element).css('color', '#FFFFFF')

        # Now say that the next click will be for adding a left bracket
        @bracketClicks = (@bracketClicks+1)%2

        # An equation starting with a left bracket needs a dot before so we can add more brackets.
        # We just added a left bracket to the start, so prepend a dot at the very start. 
        if(@leftBracketIndex == 0)
          @leftBracketIndex++
          @addDot(false, @containerSelector)

    else if(@bracketClicks == 1)
      # When we are clicking to add the right bracket (we have already clicked to add the left)
      rightBracketIndex = $(element).index(@containerSelector + ' li.dot')

      # If we clicked on a dot AFTER the place we clicked for the left bracket
      if(@leftBracketIndex < rightBracketIndex)
        # Change the dot to a right bracket
        $(element).attr('data-bracket','right')

        # Now say that the next click will be for adding a right bracket
        @bracketClicks = (@bracketClicks+1)%2

        @cleanUpBrackets()

        # Now we may need to add an extra dot at the end, when we add a right bracket at the very end
        if(rightBracketIndex == @numberDots-1)
          @addDot(true, @containerSelector)



  ###*
   * Remove brackets. We have clicked on a dot and so change 
   * @param  {DomElement} element The bracket element we clicked on
  ###
  removeBracket: (element) ->
    thisReference = this
    # if we are have balanded brackets everywhere...
    if(@bracketClicks == 0)
      # If we clicked on a left bracket
      if($(element).attr('data-bracket') is 'left')
        nextDots = $(element).nextAll('li.dot')
        counter = 1
        matchingRightBracket = undefined
        # Move from left to right until we find the matching right bracket
        for dot in nextDots
          if($(dot).attr('data-bracket') is 'left') then counter++
          if($(dot).attr('data-bracket') is 'right') then counter--
          if(counter == 0)
            matchingRightBracket = dot
            break
        # Remove the bracket pairs. Change the pair to dots and call cleanup.
        $(element).attr('data-bracket','none')
        $(matchingRightBracket).attr('data-bracket','none')
        @cleanUpBrackets()
      # If we clicked on a right bracket
      else if($(element).attr('data-bracket') is 'right') 
        prevDots = $(element).prevAll('li.dot')
        counter = 1
        matchingLeftBracket = undefined
        # Move from right to to until we find the matching left bracket
        for dot in prevDots
          if($(dot).attr('data-bracket') is 'left') then counter--
          if($(dot).attr('data-bracket') is 'right') then counter++
          if(counter == 0)
            matchingLeftBracket = dot
            break
        # Remove the bracket pairs. Change the pair to dots and call cleanup.
        $(element).attr('data-bracket','none')
        $(matchingLeftBracket).attr('data-bracket','none')
        @cleanUpBrackets()
    else if(@bracketClicks == 1)
      # We added a new left bracket
      if(not $(element).is("[data-bracketid]"))
        $(element).attr('data-bracket','none')
        @bracketClicks = 0
        @cleanUpBrackets()


  ###*
   * Fix up all the bracketing. Removes redundant dots and calls pairUpBrackets.
  ###
  cleanUpBrackets: () ->
    thisReference = this
    $(@containerSelector + ' li').each (index, d) ->
      leftBracketType = $(d).prev().attr('data-bracket')
      rightBracketType = $(d).attr('data-bracket')

      twoDotsCase = (leftBracketType is 'none') and (rightBracketType is 'none')
      leftBrkDotCase = (leftBracketType is 'left') and (rightBracketType is 'none')
      dotRightBrkCase = (leftBracketType is 'none') and (rightBracketType is 'right')
      leftBkrRightBrkCase1 = (leftBracketType is 'left') and (rightBracketType is 'right')
      leftBkrRightBrkCase2 = (leftBracketType is 'right') and (rightBracketType is 'left')

      if rightBracketType is 'none' then $(d).css('color', '')

      if (twoDotsCase || leftBrkDotCase || dotRightBrkCase || leftBkrRightBrkCase1 || leftBkrRightBrkCase2)
        # Copy the value of the right dot to the left dot accordingly
        # We *always* delete the right dot from dom ... see below (*))
        if(leftBkrRightBrkCase1)
          $(d).prev().attr('data-bracket', 'none')
        else if(leftBkrRightBrkCase2)
          $(d).prev().attr('data-bracket', 'none')
        else if(leftBrkDotCase)
          $(d).prev().attr('data-bracket', 'left')
        else if(dotRightBrkCase)
          $(d).prev().attr('data-bracket', 'right')

        # Special case for when there is just one dot left
        if(thisReference.numberDots == 2)
          $(d).prev().remove()
          thisReference.numberDots--

        # Always remove the right dot/bracket (*)
        thisReference.numberDots--
        $(d).remove()
        # Now try and clean up again
        thisReference.cleanUpBrackets()
    @pairUpBrackets()

  ###*
   * Correctly matches up pairing brackets, gives the pair an id and the same colour
  ###
  pairUpBrackets: () ->
    ref = this
    bracketsCounter = 0
    $(@containerSelector + ' li.dot').each (index, element) ->
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
   * Called by pairUpBrackets. Work out the nth brightness colour based on total number of pairs. 
   * @param  {Number} bracketsCounter The ith bracket number when matching pairs from left to right.
  ###
  getNextBracketColor: (bracketsCounter) ->
    brightnessPercent = 80-((bracketsCounter*2)/@numberDots)*50
    return "hsl(120, 50%, #{brightnessPercent}%)"