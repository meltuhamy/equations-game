class GameScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'game.html'

  # {Json[]} An of json for commentary information
  commentary: []


  # {EquationBuilder} Used to build the draft answer.
  equationBuilder: undefined


  addingDice: false

  # {Json} These are mutually exclusive contextual actions. 
  # At most one of these can be happening at a time.
  Contexts: {Neutral: 0, AllocMenu: 1, AddAnsDice: 2, MatchBracket: 3, DelAnsDice: 4}
  currentContext: undefined
  contextChangeCallback: undefined


  constructor: () -> 

  ###*
   * Load the Game Screen. This screen that shows once the goal has been set.
   * @param {Json} json Empty.
  ###
  init: (json) ->
    @drawGoal()
    @drawDiceAllocations()
    @equationBuilder = new EquationBuilder('#answers')
    @revertNeutralContext()

  
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
    @contextChangeCallback = onChange
    currentContext = contextId

  ###*
   * Change the current contextual state back to Neutral. This bypasses changeToContext.
   * @return {[type]} [description]
  ###
  revertNeutralContext: () ->
    $("#container").unbind("click")
    @contextChangeCallback = undefined
    currentContext = @Contexts.Neutral
    


  ###*
   * Called by Network telling us that a state has changed (likely a move has been made).
  ###
  onUpdatedState:() ->
    @drawDiceAllocations()


  ###*
   * We received the next turn in the game so update the allocations of the dice.
  ###
  drawDiceAllocations: () ->
    $("#required").html(DiceFace.listToHtmlByIndex(Game.globalDice, Game.getState().required))
    $("#optional").html(DiceFace.listToHtmlByIndex(Game.globalDice, Game.getState().optional))
    $('#forbidden').html(DiceFace.listToHtmlByIndex(Game.globalDice, Game.getState().forbidden))
    $("#unallocated").html(DiceFace.listToHtmlByIndex(Game.globalDice, Game.getState().unallocated))
    @addClickListeners()
    @removeAllocationMoveMenu() # Get rid of the allocation menu because it probably doesn't match dice anymore!
    @drawPlayerList()

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

  addClickListeners: () ->
    thisReference = this
    resourceList = $('#unallocated li')
    resourceList.bind 'click', (event) ->
      thisReference.allocMenuContext(this)
    $('#answer-add-dice-btn').bind 'click', (event) ->
      thisReference.addAddAnsDiceContext()

  allocMenuContext: (element) ->
    if(Game.isMyTurn())
      @changeToContext(@Contexts.AddAnsDice, @allocMenuContextChange)
      @drawAllocationMoveMenu(element)

  allocMenuContextChange: () ->
    @removeAllocationMoveMenu()

  addAddAnsDiceContext: () ->
    thisReference = this
    @changeToContext(@Contexts.AddAnsDice, @addAddAnsDiceContextChange)
    $('#answer-add-dice-btn').css('background', 'black')
    $('#answer-add-dice-btn').bind 'click', (event) ->
      thisReference.revertNeutralContext()

  addAddAnsDiceContextChange: () ->
    $('#answer-add-dice-btn').css('background', '')

 




  ###*
   * Draws the bubble-menu for letting the user choose where to move the dice they clickedOn
   * @param  {HMTLLiEntity} clickedOn The html li element (diceface) they clicked on
  ###
  drawAllocationMoveMenuButtons: (clickedOn) ->
    
    @removeAllocationMoveMenu() # Need to remove the menu to create a new one.
    # If its our turn, then open the menu else, .... for now do nothing..
  
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
    $("#mamenu-required-btn").click(=> Network.moveToRequired($('#unallocated li').index($(clickedOn))))
    $("#mamenu-optional-btn").click(=>Network.moveToOptional($('#unallocated li').index($(clickedOn))))
    $("#mamenu-forbidden-btn").click(=>Network.moveToForbidden($('#unallocated li').index($(clickedOn))))



  drawAllocationMoveMenu: (clickedOn) ->
    @drawAllocationMoveMenuButtons(clickedOn)
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
   * [addDiceContext description]
  ###
  #addDiceContext: () ->

    



  ###*
   * We received the goal of dice. This method takes in the array of dice numbers
   * to displays them in the dom. 
  ###
  drawGoal: () ->
    $("#goal-dice-ctnr").html(DiceFace.listToHtml(Game.getGoalValues()))





  addDiceToAnswerArea: (array, index) ->
    if(@equationBuilder.hasCompletedBrackets()) 
      thisReference = this

      # Work out the dice we want to add to the answer area based on index
      diceFace = DiceFace.faceToHtml(@array[index])
      html = "<li class='dice' data-index='" + index + "'><span>#{diceFace}<span></li>"
      
      # Add it to the answers
      $(@equationBuilder.addDiceToEnd(html)).bind 'click', (event) ->
        


  removeDiceFromAnswerArea: () ->

