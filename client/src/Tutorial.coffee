class Tutorial
  @window: undefined
  @windowOptions = undefined
  @steps = undefined
  @stepIds = undefined
  @nextStepIndex = 0
  @tip = undefined
  @init : ->
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

  @isValid: -> @window? and @window.length > 0

  @changeContent: (content) -> if @isValid then $('#tutorial-window-content').html(content)

  @changeHeader: (header) -> if @isValid then $('#tutorial-window-header').html(header)

  @changeWindow: (header, content) -> @changeHeader(header); @changeContent(content)

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

    @addStep 
      id: "goal"
      modal: true
      header: "Goal setting"
      content: "Great, we're in a game! You've been choosen to be the goal setter. Let's make the goal '1+2'."

    @doStepWhenScreen GoalScreen, "goal"

    @addStep
      modal: false
      tipselector: 'li.dice[data-index="0"]'
      tipmessage: 'Let\'s make the goal "1+2". Click this dice to add it to the goal.'

    @addStep
      modal: false
      tipselector: 'li.dice[data-index="4"]'
      tipmessage: 'Cool, we can see that "1" has been added below. Now let\'s add "+"'

    @addStep
      modal: false
      tipselector: 'li.dice[data-index="19"]'
      tipmessage: 'Finally, add the number "2" to the goal.'

    @addStep
      modal: false
      tipselector: '#sendgoal'
      tipmessage: 'Great, now click here to submit the goal and start the game.'

    @addStep
      id: "game"
      modal: true
      header: "We're in!"
      content: "We've finally started playing the game. Let me now show you arround."
    @doStepWhenScreen GameScreen, "game"

    @addStep
      modal: false
      tipselector: '#goal-ctnr'
      tipmessage: 'This is the goal.'
      tipnext: true

    @addStep
      tipselector: '#dice_container'
      tipmessage: 'These are the dice. We must use these to either proove that the goal is possible to achieve using these or impossible.'
      tipnext: true

    @addStep
      tipselector: '#player-list'
      tipmessage: 'This shows you the players who are in the game. The player highlighted in orange is the player whose turn it is.'
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
      




  @show: -> $(@window).modal('show')
  @hide: -> $(@window).modal('hide')
  @toggle: -> $(@window).modal('toggle')

  @addStep: ({id, header, content, tipselector, tipmessage, tipheading, modal, tipnext}) ->
    index = @steps.push {id: id, header: header, content: content, tipselector: tipselector, tipmessage: tipmessage, tipheading: tipheading, modal: modal, tipnext: tipnext}
    if id? then @stepIds[id] = index - 1

  @doStep: (stepId) ->
    nextIndex = if stepId? then @stepIds[stepId] else @nextStepIndex
    theStep = @steps[nextIndex]
    if theStep?
      {id, header, content, tipselector, tipmessage, tipheading, tipnext, modal} = theStep
      if header? then @changeHeader(header)
      if content? then @changeContent(content)
      if tipselector?
        theHtml = tipmessage+(if tipnext then '<span class="grey-button tutorial-next-button">Next &rarr;</span>' else '')
        $(tipselector).qtip 
          content: theHtml
          position: 
            my: 'top center'
            at: 'bottom center'
            viewport: $(window)
          show:
            event: false
            ready: true  
          hide: false
          events: 
            render: (event, api) ->
              if tipnext then $('.tutorial-next-button').bind 'click', ->
                api.hide()
                Tutorial.doStep()
      if modal?
        if modal then @show() else @hide()
      @steps[nextIndex] = undefined
      if modal? or (tipselector? and tipnext)
        $('.tutorial-next-button').unbind "click"
        $('.tutorial-next-button').click (=> @doStep())
      @nextStepIndex++ until @steps[@nextStepIndex]? or @nextStepIndex is @steps.length

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
          setTimeout checker, 1000
      checker()
      

