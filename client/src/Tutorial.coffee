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
                <span class="grey-button">OK, Let\'s go!</span>
              </div>
            </div>'

    @window = $(html).prependTo('body')
    $(@window).modal(@windowOptions)

  @isValid: -> @window? and @window.length > 0

  @changeContent: (content) -> if @isValid then $('#tutorial-window-content').html(content)

  @changeHeader: (header) -> if @isValid then $('#tutorial-window-header').html(header)

  @changeWindow: (header, content) -> @changeHeader(header); @changeContent(content)

  @show: -> $(@window).modal('show')
  @hide: -> $(@window).modal('hide')
  @toggle: -> $(@window).modal('toggle')

  @addStep: ({id, header, content, tipselector, tipmessage, modal}) ->
    index = @steps.push {id: id, header: header, content: content, tipselector: tipselector, tipmessage: tipmessage, modal: modal}
    if id? then @stepIds[id] = index - 1

  @doStep: (stepId) ->
    nextIndex = if stepId? then @stepIds[stepId] else @nextStepIndex
    theStep = @steps[nextIndex]
    if theStep?
      {id, header, content, tipselector, tipmessage, modal} = theStep
      if header? then @changeHeader(header)
      if content? then @changeContent(content)
      if tipselector?
        # TODO: The element needs to be selected
        $(tipselector).addClass('glow')
        # TODO: The message needs to be displayed
        if tipmessage? then alert tipmessage
      if modal?
        if modal then @show() else @hide()
      @steps[nextIndex] = undefined
      @nextStepIndex++ until @steps[@nextStepIndex]? or @nextStepIndex is @steps.length
