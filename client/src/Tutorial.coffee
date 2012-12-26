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
      backdrop: true
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
                <p>Hello!</p><p>I\'m here to show you around the basics of the equations game. Pay attention!</p>
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



  @show: -> $(@window).modal('show')
  @hide: -> $(@window).modal('hide')
  @toggle: -> $(@window).modal('toggle')

  @addStep: ({id, header, content, tipselector, tipmessage, tipheading, modal, tipnext}) ->
    index = @steps.push {id: id, header: header, content: content, tipselector: tipselector, tipmessage: tipmessage, tipheading: tipheading, modal: modal, tipnext: tipnext}
    if id? then @stepIds[id] = index - 1

  @doStep: (stepId) ->
    nextIndex = if stepId? then @stepIds[stepId] else @nextStepIndex
    theStep = @steps[nextIndex]
    $('.jquerybubblepopup').remove() # Remove all existing popups
    if theStep?
      {id, header, content, tipselector, tipmessage, tipheading, tipnext, modal} = theStep
      if header? then @changeHeader(header)
      if content? then @changeContent(content)
      if tipselector?
        theHtml = tipmessage+(if tipnext then '<span class="grey-button" id="tutorial-next-button">Next &rarr;</span>' else '')
        $(tipselector).CreateBubblePopup 
          innerHtml: theHtml
          themePath: 'lib/bubble/jquerybubblepopup-themes'
        $(tipselector).ShowBubblePopup()
        $(tipselector).FreezeBubblePopup()
        if tipnext then $('')
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
      

