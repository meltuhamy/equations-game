class GameScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'game.html'

  # {Json[]} An of json for commentary information
  commentary: []


  # {EquationBuilder} Used to build the draft answer.
  equationBuilder: undefined

  # {Is the game currently in challenge mode}
  challengeMode: false


  addingDice: false

  # {Json} These are mutually exclusive contextual actions. 
  # At most one of these can be happening at a time.
  Contexts: {Neutral: 0, AllocMenu: 1, AddAnsDice: 2, MatchBracket: 3, DelAnsDice: 4}
  currentContext: undefined
  contextChangeCallback: undefined

  # {Number[]} An array of indices to the globalDice array of dice in answer area.
  answerAreaDice: []

  # {Boolean[]} A bitmap telling us if the globalDice has been used in answer area.
  usedInAnswer: []


  constructor: () -> 

  ###*
   * Load the Game Screen. This screen that shows once the goal has been set.
   * @param {Json} json Empty.
  ###
  init: (json) ->
    @drawGoal()
    @equationBuilder = new EquationBuilder('#answers')
    @neutralContext()
    $("#now-button").bind("click", @nowButtonHandler)
    $("#never-button").bind("click", @neverButtonHandler)


  
  ###*
   * Change the current contextual state.
   * @param  {Contexts} contextId A value from Contexts
   * @param  {Function} onChange  A callback do this when the context is changed later.
   * @param  {Function} mouse A event handler for document click 
  ###
  changeToContext: (contextId, onChange, mouse) ->
    if(@contextChangeCallback?) then @contextChangeCallback()
    $("#container").unbind("click")
    if(mouse) then $("#container").bind("click", mouse)
    if(onChange?) then @contextChangeCallback = onChange
    @currentContext = contextId


  

  nowButtonHandler: () ->
    if Game.challengeMode
      Network.sendNowChallengeRequest()

  neverButtonHandler: () ->
    if Game.challengeMode
      Network.sendNeverChallengeRequest()



    


  ###*
   * Called by Network telling us that a state has changed (likely a move has been made).
  ###
  onUpdatedState:() ->
    @neutralContext()
    if(Game.challengeMode)
      $('#container').attr('data-challenge', 'now')
      $('#container').attr('data-glow', 'on')
      $('#now-button').hide()
      $('#never-button').hide()


   

  ###*
   * When the turn has changed, update the player information.
  ###
  drawPlayerList: () ->
    html = '<ul>'
    for p in Game.players
      # See whether we need to this player because its his turn
      currentHtml = if(Game.state.currentPlayer is p.index) then " class='current-turn-player'" else ""
      # See if we need to add a "(You)" to the persons name because this player *is* you!
      nameHtml = if(Game.myPlayerId is p.index) then p.name + ' (You)' else p.name
      html += '<li' + currentHtml + '>' + nameHtml + '</li>'
    html += '</ul>'
    $('#player-list').html(html)
    # If it is our turn, then make the container glow else don't make it glow
    glowOnOff = if(Game.isMyTurn()) then 'on' else 'off'
    $('#container').attr('data-glow', glowOnOff)



  ###*
   * Redraw all of the messages in the commentary box (including the now msg)
  ###
  ###drawCommentery: () ->
    now = Game.getNowCommentary
    nowHtml = '<li class="now-commentary">' + now + '</li>'
    old = Game.getOldCommentary
    oldHtml = ''
    for c in old
      oldHtml += '<li>' + c + '</li>'
  ###
    

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


    if(Game.challengeMode)
      decideHtml = '<span id="challenge-agree-btn">Agree</span> <span id="challenge-disagree-btn">Disagree</span>'
      if(Game.isChallengeDecideTurn())
        if(!Game.isChallenger())
          $('#turn-notification').html('Select if you agree: ' + decideHtml)
          $('#challenge-agree-btn').unbind 'click'
          $('#challenge-agree-btn').bind 'click', (event) ->
            Network.sendNowChallengeDecision(true)
          $('#challenge-disagree-btn').unbind 'click'
          $('#challenge-disagree-btn').bind 'click', (event) ->
            Network.sendNowChallengeDecision(false)
        else 
          $('#turn-notification').html('Please wait')
      if(Game.isChallengeSolutionTurn())
        if(Game.agreesWithChallenge())
          @changeToContext(@Contexts.Neutral, @neutralContextChange)
          $('#turn-notification').html('Submitting solutions time')
          $('#answer-submit-btn').show()
          $('#answer-submit-btn').unbind 'click'
          $('#answer-submit-btn').bind 'click', (event) ->
            thisReference.submitAnswer()
        else
          @changeToContext(@Contexts.Neutral, @neutralContextChange)

    else
      $('#answer-submit-btn').hide()
      $('#unallocated li').bind 'click', (event) ->
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
    #if(Game.isMyTurn())
    @changeToContext(@Contexts.AllocMenu, @allocMenuContextChange)
    @drawAllocationMoveMenu(element)
    thisReference = this
    $('#unallocated li').unbind('click')
    $('#unallocated li').bind 'click', (event) ->
      thisReference.allocMenuContext(this)



  allocMenuContextChange: () ->
    @removeAllocationMoveMenu()

  ### Adding a dice to answer area context ###
  addAddAnsDiceContext: () ->
    thisReference = this
    @changeToContext(@Contexts.AddAnsDice, @addAddAnsDiceContextChange)
    $('#answer-add-dice-btn').css('background', 'black')
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
    @removeAllocationMoveMenu() # Need to remove the menu to create a new one.
    #Create the new allocation menu
    html = '<div id="move-allocation-menu">
      <span id="mamenu-required-btn">Required</span>
      <span id="mamenu-optional-btn">Optional</span>
      <span id="mamenu-forbidden-btn">Forbidden</span>
      </div>'
    $('#container').append(html)
    #In general, remove the allocation menu one someone clicks any of the buttons
    $("#move-allocation-menu span").click(=>@removeAllocationMoveMenu())
    #Add event listener for each of the "required" "optional" and "forbidden" buttons inside the menu
    $("#mamenu-required-btn").click(=>Network.moveToRequired($('#unallocated li').index($(clickedOn))))
    $("#mamenu-optional-btn").click(=>Network.moveToOptional($('#unallocated li').index($(clickedOn))))
    $("#mamenu-forbidden-btn").click(=>Network.moveToForbidden($('#unallocated li').index($(clickedOn))))
    borderOffset = parseInt($(clickedOn).css('border-width'), 10) 
    $('#move-allocation-menu').css(
      left: $(clickedOn).position().left + ($(clickedOn).width()-borderOffset)/2
      top: $(clickedOn).position().top + $(clickedOn).height() + borderOffset
    )



  ###*
   * Deletes the bubble-tip menu if it exists
  ###
  removeAllocationMoveMenu: ()->
    allocMenu = $('#move-allocation-menu')
    $('#move-allocation-menu').remove() if allocMenu.length > 0



  ###*
   * We received the goal of dice. This method takes in the array of dice numbers
   * to displays them in the dom. 
  ###
  drawGoal: () ->
    $("#goal-dice-ctnr").html(DiceFace.listToHtml(Game.getGoalValues()))



  recolorAnswerDice: () ->
    for a in @answerAreaDice
      mat = ''
      for x in Game.state.unallocated
        if (a == x) then mat = 'unallocated'
      for x in Game.state.required
        if (a == x) then mat = 'required'
      for x in Game.state.optional
        if (a == x) then mat = 'optional'
      for x in Game.state.forbidden
        if (a == x) then mat = 'forbidden'

      # Store the index to the global dice array
      $("ul#answers li.dice[data-index='#{a}']").attr('data-alloc', mat)

      # Store the index to the mat array 
      #pos = $('ul#' + mat + " li.dice[data-index='{a}']").index('ul#' + mat + ' li')
      #$("ul#answers li.dice[data-index='#{a}']").attr('data-matindex', pos)
      
      $("ul#answers li.dice[data-index='#{a}']").unbind 'mouseover'
      $("ul#answers li.dice[data-index='#{a}']").bind 'mouseover', (event) ->
        $("ul#" + $(this).attr('data-alloc') + " li.dice[data-index='" + $(this).attr('data-index') + "']").attr('data-anshover', 'on')

      $("ul#answers li.dice[data-index='#{a}']").unbind 'mouseleave'
      $("ul#answers li.dice[data-index='#{a}']").bind 'mouseleave', (event) ->
        $("ul#" + $(this).attr('data-alloc')+" li.dice[data-index='" + $(this).attr('data-index') + "']").attr('data-anshover', 'off')

      $("ul#" + mat + " li.dice[data-index='"+a+"']").attr('data-usedinans', 'true')




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


  submitAnswer: () ->
    answer = @equationBuilder.getIndicesToGlobalDice()
    Network.sendNowChallengeSolution(answer)
