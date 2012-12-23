class Tutorial
  @window: undefined
  @windowOptions = undefined
  @steps = undefined
  @stepIds = undefined
  @nextStepIndex = 0
  @init : ->
    if $('#tutorial-window').length > 0 then $('#tutorial-window').remove()
    @steps = []
    @stepIds = []
    @windowOptions = 
      backdrop: false
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
                <span class="grey-button" id="tutorial-next-button">Next &rarr;</span>
              </div>
            </div>'

    @window = $(html).prependTo('body')
    $('#tutorial-next-button').click (=> @doStep())
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
      modal: true
      header: "Goal setting"
      content: "Great, we're in a game! You've been choosen to be the goal setter."



  @show: -> $(@window).modal('show')
  @hide: -> $(@window).modal('hide')
  @toggle: -> $(@window).modal('toggle')

  @addStep: ({id, header, content, tipselector, tipmessage, tipheading, modal}) ->
    index = @steps.push {id: id, header: header, content: content, tipselector: tipselector, tipmessage: tipmessage, tipheading: tipheading, modal: modal}
    if id? then @stepIds[id] = index - 1

  @doStep: (stepId) ->
    nextIndex = if stepId? then @stepIds[stepId] else @nextStepIndex
    theStep = @steps[nextIndex]
    if theStep?
      {id, header, content, tipselector, tipmessage, tipheading, modal} = theStep
      if header? then @changeHeader(header)
      if content? then @changeContent(content)
      if tipselector?
        # TODO: The element needs to be selected
        # TODO: The message needs to be displayed
        $(tipselector).popover 
          html: true
          title: tipheading
          content: tipmessage

        $(tipselector).popover('show')
      if modal?
        if modal then @show() else @hide()
      @steps[nextIndex] = undefined
      @nextStepIndex++ until @steps[@nextStepIndex]? or @nextStepIndex is @steps.length
