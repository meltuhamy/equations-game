###*
 * class GameScreen extends Screen
###
class GameScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'game.html'

  # {EquationBuilder} Used to build the draft answer.
  #equationBuilder: undefined


  #addingDice: false

  # {Json} These are mutually exclusive contextual actions. 
  # At most one of these can be happening at a time.
  Contexts: {Neutral: 0, AllocMenu: 1, AddAnsDice: 2, MatchBracket: 3, DelAnsDice: 4}
  #currentContext: undefined
  #contextChangeCallback: undefined

  # {Number[]} An array of indices to the globalDice array of dice in answer area.
  #answerAreaDice: []

  # {Boolean[]} A bitmap telling us if the globalDice has been used in answer area.
  #usedInAnswer: []

  # {Boolean} Have we submitted the solution
  #submittedSolution: false

  # {Boolean} Have we submitted our decision for the challenge
  #ubmittedDecision: false

  # {Sketcher} The HTML5 drawing area
  #sketcher: undefined

  # {Integer} The id of the interval for the turn timer
  #turnTimer: undefined
  #
  # {Boolean} Is the game paused?
  #isPaused: false

  knobSettings: {width:50,height:50,fgColor:'#87CEEB',bgColor:'#EEEEEE',displayInput: false}


  constructor: () -> 

  ###*
   * Load the Game Screen. This screen that shows once the goal has been set.
   * @param {Json} json Empty.
  ###
  init: (json) ->
    @equationBuilder = undefined
    @addingDice = false
    @currentContext = undefined
    @contextChangeCallback = undefined
    @answerAreaDice = []
    @usedInAnswer = []
    @sketcher = undefined
    @submittedSolution = false
    @submittedDecision = false
    @turnTimer = undefined
    @knobInterval = 100
    @isPaused = false

    
    @drawGoal()
    @equationBuilder = new EquationBuilder('#answers')
    @neutralContext()
    $("#now-button").bind("click", @nowButtonHandler)
    $("#never-button").bind("click", @neverButtonHandler)
    

    # Add the leave, help and log button to the bottom right floating toolbar
    # Add the commentary log to the bottom right floating toolbar. Make it hidden
    toolbarhtml = '<ul id="bottom-log"></ul>'
    toolbarhtml += '<a href="#" id="log-button">Turns Log</a>'
    toolbarhtml += ' <a href="#" id="leave-button">Leave Game</a>'
    toolbarhtml += ' <a href="#">Help</a>'
    $('#bottom-toolbar').html(toolbarhtml)

    # TODO: make the help button do something (eg. go to a manual - which doesn't current exist)
    $("#leave-button").bind("click", @leaveButtonHandler)
    $("#log-button").bind("click", @logButtonHandler)


    ### Sketcher stuf ###
    @initSketcher()
    ### Timer Knob ###
    $('#timer-knob').knob(@knobSettings)


  ###*
   * Initialises the html sketcher element
   * @return {[type]} [description]
  ###
  initSketcher: () ->
    cv = document.getElementById("simple_sketch")
    ctx = cv.getContext("2d")

    #Set the canvas size to fit its parent div
    ctx.canvas.width = $(cv).parent().width()
    ctx.canvas.height = $(cv).parent().height()

    #On window resize, resize canvas too.
    $(window).resize ->
      ctx.canvas.width = $(cv).parent().width()
      ctx.canvas.height = $(cv).parent().height()
    @sketcher = new Sketcher("simple_sketch")

    #Click listeners for the sketch buttons
    thisReference = this
    $("#sketchClear").click (event) ->
      thisReference.sketcher.clear()
    $("#sketchPencil").click (event) ->
      thisReference.sketcher.changeToPencil()
    $("#sketchRubber").click (event) ->
      thisReference.sketcher.changeToRubber()


  ###*
   * Change the current contextual state.
   * @param  {Contexts} contextId A value from Contexts
   * @param  {Function} onChange  A callback do this when the context is changed later.
   * @param  {Function} mouse A event handler for document click 
  ###
  changeToContext: (contextId, onChange, mouse) ->
    if(@contextChangeCallback?) then @contextChangeCallback()
    $(document).unbind("click")
    if(mouse?) then $(document).bind("click", mouse)
    if(onChange?) then @contextChangeCallback = onChange
    @currentContext = contextId



  nowButtonHandler: () ->
    if !Game.challengeMode then network.sendNowChallengeRequest()

  neverButtonHandler: () ->
    if !Game.challengeMode then network.sendNeverChallengeRequest()

  leaveButtonHandler: () ->
    window.location.reload()


  # When the game state has changed on the server do this...
  onUpdatedState:() ->
    @neutralContext()
    
    $('#timer-knob').trigger 'configure', {min: 0, max: Game.state.turnDuration * 1000/@knobInterval}
    if(Game.challengeMode)
      $('#container').attr('data-challenge', 'now')
      $('#container').attr('data-glow', 'on')
      $('#now-button').hide()
      $('#never-button').hide()

    # Update the commentary log link
    #ifCommentary.log.length > 0)
      

    # Add a setinterval (faster than 1sec) to countdown the timer
    if !@isPaused
      thisReference = this
      $('#timer-knob').val(Game.state.turnDuration).trigger('change');
      value = @getKnobFaceTime()
      $('#timer-text-ctnr').html("#{value}")
      @resetKnobTimer()

  resetKnobTimer: ()->
    thisReference = this
    clearInterval(@turnTimer)
    @turnTimer = setInterval ->
      thisReference.doChangeKnob(thisReference)
    , @knobInterval

  onPauseTimer:() ->
    clearInterval(@turnTimer)
    @isPaused = true

  onResumeTimer:() ->
    @isPaused = false
    @resetKnobTimer()

  # When the player has changed on a state change
  onUpdatedPlayerTurn:() ->



  doChangeKnob: (ref) ->
    timeElapsed = Game.state.turnDuration*(1000/ref.knobInterval) - (Math.floor((Date.now() - Game.state.turnStartTime)))/ref.knobInterval
    $('#timer-knob').val(timeElapsed).trigger('change')
    value = ref.getKnobFaceTime()
    $('#timer-text-ctnr').html("#{value}")
    if value<=0 then clearInterval(@turnTimer)

  getKnobFaceTime: () -> Math.round(Game.state.turnDuration - (Math.floor((Date.now() - Game.state.turnStartTime)))/1000)




  ###*
   * When the turn has changed, update the player list (with whose turn it is).
  ###
  drawPlayerList: () ->
    html = '<ul>'
    # Go through the list of players and draw them.
    for p in Game.players
      # For each player, draw their name with an icon. 
      # By default there is no tag below their name. By default they are not highlighted.
      tag = ''
      isHighlighted = false
      # If it's not challenge mode, if it's the players current turn, then highlight his icon
      if(!Game.challengeMode)
        if(Game.state.currentPlayer is p.index) then isHighlighted = true
      else
        # If it's challenge mode, add tags below the players to show if they are
        # the challenger/agree/disagree/havent decided. Highlight them if they have't decided.
        if(!Game.hasPlayerDecided(p.index))
          tag = "Not Decided"
        else if(p.index == Game.challengerId)
          tag = "Challenger"
        else if(Game.doesPlayerAgreeChallenge(p.index))
          tag = "Agreed"
        else if(!Game.doesPlayerAgreeChallenge(p.index))
          tag = "Disagreed"
        isHighlighted = !Game.hasPlayerDecided(p.index)
      # See whether we need to highlight this player's icon orange 
      highlightHtml = if isHighlighted then " class='current-turn-player'" else ""
      # See if we need to add a "(You)" to the persons name because this player *is* you!
      nameHtml = p.name
      if(Game.myPlayerId is p.index) then nameHtml += ' (You)'
      # Add the player to the list
      html += '<li' + highlightHtml + '>' + nameHtml
      if(tag != '') then html += "<br/><span class='challenge-tag'>#{tag}</span>"
      html += "</li>"
    html += '</ul>'
    $('#player-list').html(html)
    


  #######################################################################
  ##==============   Comnmentary and Logs   ============================#
  #######################################################################

  logButtonHandler: () ->
    $('#bottom-log').slideToggle("fast")

  updateLog: () ->
    # The log of events may have changed. this functions redraws the log with all the log-commentary
    logHtml = '' # rewrite everything from scratch
    for c in Commentary.log
      logHtml = '<li>' + c.short + '</li>' + logHtml
    $('#bottom-log').html(logHtml)




  # Draw Now-Commentary (commentary in the center of screen) for what's going on during allocation turns
  drawCommentaryForAllocating: () ->
    # If it's our turn for allocating, 
    if(Game.isMyTurn())
      # highlight the allocations area orange and give a message to say its our turn.
      $('#container').attr('data-glow', 'on')
      $('div#allocation_container').attr('data-attention', 'on')
      $('div#turn-notification').attr('data-attention', 'on')
      $('span#now-commentary').html('It\'s your turn! Choose a dice from unallocated to move to another mat.')
    else
      # Somebody else's turn. Make it unhighlighted + write a different msg.
      $('#container').attr('data-glow', 'off')
      $('div#allocation_container').attr('data-attention', 'off')
      $('#turn-notification').attr('data-attention', 'off')
      name = Game.getCurrentTurnPlayerName()
      $('span#now-commentary').html('It is ' + name + '\'s turn to move a dice from unallocated to another mat.')



  # Draw Now-Commentary (commentary in the center of screen) for what's going on during challenges
  drawCommentaryForChallenges: () ->
    # We have a now/never challenge. Draw the buttons to let him agree/disagree
    buttonsHtml = '<span id="challenge-agree-btn">Agree</span> <span id="challenge-disagree-btn">Disagree</span>'
    thisReference = this

    # De-highlight the area for allocating dice. We're done with all that now. It's challenge time.
    $('div#allocation_container').attr('data-attention', 'off')

    # Right now, people are choosing to agree/disagree with challenge. Have we decided yet?
    if(Game.isChallengeDecideTurn())
      # We haven't decided yet. Highlight the notification area orange and add buttons to let us decide.
      if(!Game.isChallenger() && !@submittedDecision)
          # Highlight the notification area orange
          $('#turn-notification').attr('data-attention', 'on')
          # Html for the buttons
          html = if(Game.challengeModeNow) then "Now Challenge! " else "Never Challenge! "
          html += "Please select if you agree: "
          html += buttonsHtml
          $('span#now-commentary').html(html)
          # Event Handler for agreeing
          $('#challenge-agree-btn').unbind 'click'
          $('#challenge-agree-btn').bind 'click', (event) ->
            network.sendChallengeDecision(true)
            thisReference.submittedDecision = true
          # Event Handler for disagreeing
          $('#challenge-disagree-btn').unbind 'click'
          $('#challenge-disagree-btn').bind 'click', (event) ->
            network.sendChallengeDecision(false)
            thisReference.submittedDecision = false
      else
        # We have decided. Make the notification area say that we are waiting.
        $('span#now-commentary').html('Please wait for other players to decide.')
        $('#turn-notification').attr('data-attention', 'off')
    else if(Game.isChallengeSolutionTurn())
      # Right now, people are submitting solutions. 
      # Do we need to submit a solution? Have we submitted a solution yet?
      if(Game.solutionRequired())
        if(@submittedSolution)
          # We submitted a required solution. Make the notification area say that we are waiting.
          $('#turn-notification').attr('data-attention', 'off')
          $('#answer-area').attr('data-attention', 'off')
          $('span#now-commentary').html('Please wait for other players to submit their solutions')
        else
          # We have't submitted a required solution. Make notification area say we need to submit a solution.
          # Force the menu context mode to adding dice
          @addAddAnsDiceContext()
          # Highlight the notification area and the dice answer area. Add msg to notification area.
          $('#turn-notification').attr('data-attention', 'on')
          $('#answer-area').attr('data-attention', 'on')
          $('span#now-commentary').html('Please submit your solution.')
          # Show the button for submitting a solution and bind it to a submission event
          $('#answer-submit-btn').show()
          $('#answer-submit-btn').unbind 'click'
          $('#answer-submit-btn').bind 'click', (event) ->
            thisReference.submitAnswer()
      else
        # We didn't need to submit a solution. Make the notification area say that we are waiting.
        $('#turn-notification').attr('data-attention', 'off')
        $('#answer-area').attr('data-attention', 'off')
        $('span#now-commentary').html('Please wait for other players to submit their solutions.')
  

  #######################################################################
  ##======================   Contexts   ================================#
  #######################################################################

  neutralContext: () ->
    @changeToContext(@Contexts.Neutral, @neutralContextChange)

    
    $("#required").html(DiceFace.listToHtmlByIndex(Game.globalDice, Game.getState().required, true))
    $("#optional").html(DiceFace.listToHtmlByIndex(Game.globalDice, Game.getState().optional, true))
    $('#forbidden').html(DiceFace.listToHtmlByIndex(Game.globalDice, Game.getState().forbidden, true))
    $("#unallocated").html(DiceFace.listToHtmlByIndex(Game.globalDice, Game.getState().unallocated, true))

    thisReference = this 
    $('#unallocated li').unbind('click')
    $('#optional li').unbind('click')
    $('#required li').unbind('click')


    # Update commentary box to update progress on challenges and show agree/disagree buttons etc.
    @updateLog()
    if(Game.challengeMode)
      $('#challenge-title').show()
      $('#challenge-title').html(Game.getChallengeName())
      @drawCommentaryForChallenges()
    else
      $('#challenge-title').hide()
      $('#answer-submit-btn').hide()
      @drawCommentaryForAllocating()
      $('#unallocated li').bind 'click', (event) ->
        event.stopPropagation()
        thisReference.allocMenuContext(this)

    $('#answer-add-dice-btn').unbind('click')
    $('#answer-add-dice-btn').bind 'click', (event) ->
      thisReference.addAddAnsDiceContext()

    @drawPlayerList()
    @recolorAnswerDice()

  neutralContextChange: () ->
    #$('#unallocated li').unbind('click')


  ### Allocation menu context ###
  allocMenuContext: (element) ->
    if(Game.isMyTurn())
      thisReference = this
      $('#unallocated li').unbind('click')
      $('#unallocated li').bind 'click', (event) ->
        thisReference.allocMenuContext(this)
        event.stopPropagation()

      # Change the context to say the menu is now open
      @changeToContext(@Contexts.AllocMenu, @allocMenuContextChange)
      @drawAllocationMoveMenu(element)
     


  removeAllocationMoveMenu: () ->
    if @allocationMoveMenuOn? then $(@allocationMoveMenuOn).qtip('hide')

  allocMenuContextChange: () ->
    @removeAllocationMoveMenu()

  ### Adding a dice to answer area context ###
  addAddAnsDiceContext: () ->
    thisReference = this
    @changeToContext(@Contexts.AddAnsDice, @addAddAnsDiceContextChange)
    $('#answer-add-dice-btn').css('background', '#CE8400')
    $('#answer-add-dice-btn').unbind ('click')
    $('#answer-add-dice-btn').bind 'click', (event) ->
      thisReference.neutralContext()
    $('#unallocated li').unbind ('click')
    $('#unallocated li').bind 'click', (event) ->
      thisReference.addDiceToAnswerArea(parseInt($(this).attr('data-index')))
    $('#required li').unbind ('click')
    $('#required li').bind 'click', (event) ->
      thisReference.addDiceToAnswerArea(parseInt($(this).attr('data-index')))
    $('#optional li').unbind ('click')
    $('#optional li').bind 'click', (event) ->
      thisReference.addDiceToAnswerArea(parseInt($(this).attr('data-index')))


  addAddAnsDiceContextChange: () ->
    $('#answer-add-dice-btn').css('background', '')

 
  ###*
   * Draws the bubble-menu for letting the user choose where to move the dice they clickedOn
   * @param  {HMTLLiEntity} clickedOn The html li element (diceface) they clicked on
  ###
  drawAllocationMoveMenu: (clickedOn) ->
    @allocationMoveMenuOn = clickedOn
    console.log "draw Allocation menu"
    console.log clickedOn
    #Create the new allocation menu
    html = '<br /><span id="mamenu-required-btn" class="mamenu-button">Required</span>
            <span id="mamenu-optional-btn" class="mamenu-button">Optional</span>
            <span id="mamenu-forbidden-btn" class="mamenu-button">Forbidden</span>'
    $(clickedOn).qtip 
      id: 'move-allocation'
      content:
        text: html
        title:
          text: 'Move dice to...'
          button: true
      position: 
        my: 'top center'
        at: 'bottom center'
        viewport: $(window)
        adjust:
          y: -5
      show:
        event: 'click'
        button: true 
        effect: -> $(this).fadeIn(400)
        ready: true
      hide:
        event: 'unfocus'
        effect: -> $(this).fadeOut(100)
      style:
        classes: 'qtip-shadow qtip-light qtip-rounded'
        width: '230px'
        height: '70px'
      events: 
        render: (event, api) ->
          console.log "Render fired"
          #Add event listener for each of the "required" "optional" and "forbidden" buttons inside the menu
          clickedIndex = $('#unallocated li').index($(clickedOn))
          $("#mamenu-required-btn").click -> network.moveToRequired(clickedIndex)
          $("#mamenu-optional-btn").click -> network.moveToOptional(clickedIndex)
          $("#mamenu-forbidden-btn").click -> network.moveToForbidden(clickedIndex)

          #In general, remove the allocation menu one someone clicks any of the buttons
          $(".mamenu-button").click (event) -> api.hide()

        hidden: (event, api) ->
          # Removes the buttons since even though they're hidden, they're still there.
          # This fixes the click listner bug.
          $('.mamenu-button').remove()



  ###*
   * We received the goal of dice. This method takes in the array of dice numbers
   * to displays them in the dom. 
  ###
  drawGoal: () ->
    $("#goal-dice-ctnr").html(DiceFace.listToHtml(Game.getGoalValues()))


  #######################################################################
  ##=====================   Answer Area  ===============================#
  #######################################################################


  ###*
   * We have dice in our answer area. They need to be recoloured as dice move 
   * between allocation mats. Naively go through all the dice and colour them appropriately.
  ###
  recolorAnswerDice: () ->
    # These two vars are used later in writeAnswerAreaNotices
    @answerForbiddenDiceCount = 0
    @answerRequiredDiceCount = 0

    for a in @answerAreaDice
      mat = ''
      for x in Game.state.unallocated
        if (a == x) then mat = 'unallocated'
      for x in Game.state.required
        if (a == x)
          mat = 'required'
          @answerRequiredDiceCount++
      for x in Game.state.optional
        if (a == x) then mat = 'optional'
      for x in Game.state.forbidden
        if (a == x)
          mat = 'forbidden'
          @answerForbiddenDiceCount++

      # Store the index to the global dice array
      $("ul#answers li.dice[data-index='#{a}']").attr('data-alloc', mat)

      # Store the index to the mat array 
      #pos = $('ul#' + mat + " li.dice[data-index='{a}']").index('ul#' + mat + ' li')
      #$("ul#answers li.dice[data-index='#{a}']").attr('data-matindex', pos)
      
      # Add some nice events so that when we hover over the answer dice, the corresponding dice
      # in the allocation mat glows a bit - so we can see which dice exactly was added to the answer area
      $("ul#answers li.dice[data-index='#{a}']").unbind 'mouseover'
      $("ul#answers li.dice[data-index='#{a}']").bind 'mouseover', (event) ->
        $("ul#" + $(this).attr('data-alloc') + " li.dice[data-index='" + $(this).attr('data-index') + "']").attr('data-anshover', 'on')

      $("ul#answers li.dice[data-index='#{a}']").unbind 'mouseleave'
      $("ul#answers li.dice[data-index='#{a}']").bind 'mouseleave', (event) ->
        $("ul#" + $(this).attr('data-alloc')+" li.dice[data-index='" + $(this).attr('data-index') + "']").attr('data-anshover', 'off')

      $("ul#" + mat + " li.dice[data-index='"+a+"']").attr('data-usedinans', 'true')
    @writeAnswerAreaNotices()

  ###*
   * Called by: recolorAnswerDice
   * This calculates the notices that should be displayed (e.g. you have a forbidden dice) based 
   * on what dice are in the answer area and what mat each answer dice is in.
  ###
  writeAnswerAreaNotices: () ->
    $('#answer-empty-notice').html('')
    $('#answer-submit-notice').html('')
    $('#answer-required-notice').html('')
    $('#answer-forbidden-notice').html('')

    # Giving a notice saying they have no dice.
    if(Game.isChallengeSolutionTurn() && Game.solutionRequired() && !@submittedSolution)
      # Giving a notice saying they need to submit their solution for a challenge
      $('#answer-submit-notice').html('You need to submit a solution for the challenge.')
      if(@answerRequiredDiceCount < Game.state.required.length)
        # Giving a notice saying they haven't used all the required dice
        $('#answer-required-notice').html('You have not used all the required dice.')
      else if(@answerForbiddenDiceCount > 0)
        # Giving a notice saying the have used at least one forbidden dice
        $('#answer-forbidden-notice').html("Your answer has #{@answerForbiddenDiceCount} forbidden dice.")
    else if(Game.isChallengeSolutionTurn() && !Game.solutionRequired())
      $('#answer-empty-notice').html("You can't submit a solution for the challenge.")
    else if(@answerAreaDice.length == 0)
      $('#answer-empty-notice').html('You have no dice added.')



  addDiceToAnswerArea: (index) ->
    # Only let him add dice to the area if his brackets are complete
    # and if the dice hasn't already been added
    if(@equationBuilder.hasCompletedBrackets() && $.inArray(index, @answerAreaDice) is -1)
      thisReference = this
      # Work out dice face from global dice array then make the html. add to list. add to dom
      @answerAreaDice.push(index)
      diceFace = DiceFace.faceToHtml(Game.globalDice[index])
      html = "<li class='dice' data-index='" + index + "'><span>#{diceFace}<span></li>"
      # Add it to the answers
      $(@equationBuilder.addDiceToEnd(html)).bind 'click', (event) ->
        pos = $('li.dice[data-index="#{index}"]').index('ul#answers li')
        thisReference.removeDiceFromAnswerArea(pos, $(this).data('index'));
      @recolorAnswerDice()

  removeDiceFromAnswerArea: (pos, index) ->
    # Find the corresponding mat and the dice in the mat and tell it that it's no longer
    # used in our ans (usedinans=false). Also remove hover highlighting (anshover=false)
    theDice = $("ul#answers li.dice[data-index='#{index}']")
    theMat = theDice.attr('data-alloc')
    theIndex = theDice.attr('data-index')
    $("ul##{theMat} li.dice[data-index='#{theIndex}']").attr('data-usedinans', 'false')
    $("ul##{theMat} li.dice[data-index='#{theIndex}']").attr('data-anshover', 'false')
    # Now remove the dice from the answer area
    @answerAreaDice.splice(pos, 1)
    removedElement = @equationBuilder.removeDiceByIndex(index)
    @recolorAnswerDice()


  submitAnswer: () ->
    answer = @equationBuilder.getIndicesToGlobalDice()
    @submittedSolution = true
    network.sendChallengeSolution(answer)
    $('#answer-submit-btn').hide()
    $('#answer-add-dice-btn').hide()
    @neutralContext()
