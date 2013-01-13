class Tutorial
  @window: undefined
  @windowOptions: undefined
  @steps: undefined
  @stepIds: undefined
  @nextStepIndex: 0
  @tip: undefined

  ###*
   * Initialises the tutorial system's variables and configuration
  ###
  @init : ->
    @window = undefined
    @windowOptions = undefined
    @steps = undefined
    @stepIds = undefined
    @nextStepIndex = 0
    @tip = undefined

    if $('#tutorial-window').length > 0 then $('#tutorial-window').remove()

    @steps = []
    @stepIds = []
    @tip = []
    @windowOptions = 
      backdrop: 'static'
      keyboard: false
      show: false

    @initSteps()

    @nextStepIndex = 0

    html = '<div id="tutorial-window" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
              <div class="modal-header">
                <!--<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>-->
                <h3 id="tutorial-window-header">Equations Tutorial Game</h3>
              </div>
              <div class="modal-body" id="tutorial-window-content">
              </div>
              <div class="modal-footer">
                <!--<span class="grey-button" data-dismiss="modal" aria-hidden="true">Close</span>-->
                <span class="grey-button tutorial-next-button">Next &rarr;</span>
              </div>
            </div>'

    @window = $(html).prependTo('body')
    $('.tutorial-next-button').click (=> @doStep())
    $(@window).modal(@windowOptions)


  ###*
   * Adds a step to the tutorial system (in)
   * @param {String} id        An identification to give to that particular step
   * @param {String} header      The header of the modal window if one exists
   * @param {String} content     The content of the modal window if one exists
   * @param {CSS Selector} tipselector The css selector to add a tip to
   * @param {String} tipmessage  The html to add to the tip if one exists
   * @param {String} tipheading  The html to add to the heading of the tip if one exists
   * @param {Boolean} modal       Do we want the window to be modal?
   * @param {Boolean} tipnext   Do we want a next button inside the tip?
   * @param {function} callback  A function that would be called when the step is executed.
  ###
  @addStep: ({id, header, content, tipselector, tipmessage, tipheading, modal, tipnext, callback}) ->
    index = @steps.push {id: id, header: header, content: content, tipselector: tipselector, tipmessage: tipmessage, tipheading: tipheading, modal: modal, tipnext: tipnext, callback:callback}
    if id? then @stepIds[id] = index - 1

  ###*
   * Executes the next step in sequence OR executes the step with the given ID
   * @param  {String} stepId If given, the step with this ID will be executed. Otherwise, the next step will be executed.
  ###
  @doStep: (stepId) ->
    nextIndex = if stepId? then @stepIds[stepId] else @nextStepIndex
    theStep = @steps[nextIndex]
    if theStep?
      {id, header, content, tipselector, tipmessage, tipheading, tipnext, modal, callback} = theStep
      if header? then @changeHeader(header)
      if content? then @changeContent(content)
      if tipselector?
        # Hide previous exists
        prevStep = @steps[nextIndex-1]
        if prevStep? and prevStep.tipselector? then $(prevStep.tipselector).qtip('hide')
        @displayTip(tipselector, tipmessage, tipheading, tipnext)
      if modal?
        if modal then @show() else @hide()
      if modal? or (tipselector? and tipnext)
        $('.tutorial-next-button').unbind "click"
        $('.tutorial-next-button').click (=> @doStep())
      if callback? then callback()
      @steps[nextIndex].done = true
      @nextStepIndex++ until !@steps[@nextStepIndex]? or !@steps[@nextStepIndex].done or @nextStepIndex is @steps.length

  ###*
   * Executes a step with given step id only when the current screen
   * is an instance of the given class name. This is done using a timer
   * to periodically check if the screen has changed.
   * 
   * @param  {function} className The actual class name (note: not a string)
   * @param  {String} stepId    The step id to execute
  ###
  @doStepWhenScreen: (className, stepId) ->
    if typeof className is "function"
      thisReference = this
      stepid = stepId
      doThis = -> thisReference.doStep(stepid)
      checker = ->
        currentScreen = ScreenSystem.currentScreen
        if currentScreen instanceof className
          doThis()
        else
          setTimeout checker, 500
      checker()

  ###*
   * Shows the tutorial modal box (bootstrap) window
  ###
  @show: -> $(@window).modal('show')

  ###*
   * Hides the tutorial modal box (bootstrap) window
  ###
  @hide: -> $(@window).modal('hide')

  ###*
   * Toggles the tutorial modal box (bootstrap) window
  ###
  @toggle: -> $(@window).modal('toggle')


  ###*
   * Displays a qTip2 tip on the given selector.
   * @param  {String} tipselector The css selector to add a bubble tip to.
   * @param  {String} tipmessage  The message the tip will have
   * @param  {String} tipheading  The html heading the tip will have
   * @param  {Boolean} tipnext    Whether or not we want a next button in the tip.
  ###
  @displayTip: (tipselector, tipmessage, tipheading, tipnext) ->
    nextHtml = if tipnext then '<p style="text-align:right"><span class="grey-button tutorial-next-button">Next &rarr;</span></p>' else ''
    theHtml = tipmessage+nextHtml
    $(tipselector).qtip 
      content: theHtml
      position: 
        my: 'top center'
        at: 'bottom center'
        viewport: $(window)
        adjust:
          y: -5
      show:
        event: false
        ready: true  
      hide:
        event: false
        effect: -> $(this).fadeOut()
      style:
        classes: 'qtip-shadow qtip-rounded qtip-bootstrap qtip-tutorial'
        tip:
          width: 11
          height: 9
      events: 
        render: (event, api) ->
          if tipnext then $('.tutorial-next-button').bind 'click', ->
            api.hide()
            Tutorial.doStep()

  ###*
   * Returns whether or not the window exists
   * @return {Boolean} True if the window exists.
  ###
  @isValid: -> @window? and @window.length > 0

  ###*
   * Changes the content part of the window
   * @param  {String} content The html that would go into the content
  ###
  @changeContent: (content) -> if @isValid then $('#tutorial-window-content').html(content)

  ###*
   * Changes the header part of the window
   * @param  {String} header The html that would go into the header
  ###
  @changeHeader: (header) -> if @isValid then $('#tutorial-window-header').html(header)

  ###*
   * Changes the content and header parts of the window
   * @param  {String} content The html that would go into the content
   * @param {String} header The html that would go into the header
  ###
  @changeWindow: (header, content) -> @changeHeader(header); @changeContent(content)




#####################################################################################
#                         The actual steps of the tutorial.                         #
#####################################################################################

  ###*
   * Adds all the steps of the tutorial system. These steps are added *in order*
  ###
  @initSteps: ->
    @addStep
      header: 'Welcome to the Equations Tutorial!'
      content: 'Why hello there young chap. Welcome to Equations! In no time, you\'ll be up and running and ready to play'
      modal: true

    @addStep 
      header: "The Lobby"
      content: "We're now in the Lobby. Here, we get to see what games are available to join, or we could create our own game."

    @addStep 
      header: "Join a game"
      content: "Let's get started! So there's a game that is available to join right now."
      modal: true

    @addStep 
      modal: false
      tipselector: 'tr[data-gamenumber="0"] td:first-child'
      tipheading: 'Join this game'
      tipmessage: 'Click here to join the game!'
      callback: =>
        @addStep 
          id: "goal"
          modal: true
          header: "Goal setting"
          content: "Great, we're in a game! You've been chosen to be the goal setter. Let's make the goal '1+2'."
        @doStepWhenScreen GoalScreen, "goal"

    @addStep
      modal: false
      tipselector: 'li.dice[data-index="0"]'
      tipmessage: 'Let\'s make the goal "1+2". Click this dice to add it to the goal.'

    @addStep
      modal: false
      tipselector: 'li.dice[data-index="4"]'
      tipmessage: 'Cool, we can see that "1" has been added below. Now let\'s add "+".'

    @addStep
      modal: false
      tipselector: 'li.dice[data-index="19"]'
      tipmessage: 'Finally, add the number "2" to the goal.'

    @addStep
      modal: false
      tipselector: '#sendgoal'
      tipmessage: 'Great, now click here to submit the goal and start the game.'
      callback: =>
        @addStep
          id: "game"
          modal: true
          header: "We're in!"
          content: "We've finally started playing the game. Let me now show you around."
        @doStepWhenScreen GameScreen, "game"

    @addStep
      modal: false
      tipselector: '#goal-ctnr'
      tipmessage: 'This is the goal.'
      tipnext: true

    @addStep
      tipselector: '#dice_container'
      tipmessage: 'These are the dice. We must use these to either prove that the goal is possible to achieve using these dice or impossible.'
      tipnext: true

    @addStep
      tipselector: '#player-list'
      tipmessage: 'This shows you the players who are in the game. The player highlighted in orange is the player whose turn it currently is.'
      tipnext: true

    @addStep
      tipselector: '#timer-knob-ctnr'
      tipmessage: 'This is the turn timer. A player must make a move on the dice within this time if it is their turn.'
      tipnext: true

    @addStep
      tipselector: '#rough-area-board'
      tipmessage: 'This is your personal rough area. Feel free to take notes and do rough working here.'
      tipnext: true

    @addStep
      modal: true
      header: "It's your turn"
      content: "We must now make a move. Try clicking on one of the dice to move it to another area of the mat."

    @addStep
      modal: false

    @addStep
      modal: true
      header: "Forbidden, required and optional"
      content: "As you can see, in a move, you can move a die to one of three areas of the board:
      <ul>
      <li>Forbidden: The forbidden section includes all dice that can not be used when forming a solution to the goal.</li> 
      <li>Optional: You can use any number of optional dice to form the goal.</li>
      <li>Required: You must use ALL of these dice when forming the goal.</li>
      The idea is that when someone makes a 'challenge', you must use a combination of NONE of the forbidden dice, ANY of the optional dice and ALL of the required dice to form your solution to the goal.
      </ul>
      "

    @addStep
      modal: false
      