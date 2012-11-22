class GameScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'game.html'

  # {Json[]} An of json for commentary information
  commentary: []

  constructor: () -> 

  ###*
   * Load the Game Screen. This screen that shows once the goal has been set.
   * @param {Json} json Empty.
  ###
  init: (json) ->
    @drawGoal()
    @drawDiceAllocations()

  ###*
   * We received the next turn in the game so update the allocations of the dice.
  ###
  drawDiceAllocations: () ->
    $("#required").html(DiceFace.listToHtml(Game.getState().required))
    $("#optional").html(DiceFace.listToHtml(Game.getState().optional))
    $('#forbidden').html(DiceFace.listToHtml(Game.getState().forbidden))
    $("#unallocated").html(DiceFace.listToHtml(Game.getState().unallocated))
    @addClickListeners()
    @removeAllocationMoveMenu # Get rid of the allocation menu because it probably doesn't match dice anymore!
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


  ###*
   * Redraw all of the messages in the commentary box (including the now msg)
  ###
  ###drawCommentery: () ->
    now = Game.getNowCommentary
    nowHtml = '<li class="now-commentary">' + now + '</li>'
    old = Game.getOldCommentary
    oldHtml = ''
    for c in old
      oldHtml += '<li><span>' + c + '</li>'
  ###


  addClickListeners: () ->
    thisReference = this
    resourceList = $('#unallocated li')
    resourceList.bind 'click', (event) ->
      thisReference.drawAllocationMoveMenu(this);

  ###*
   * Draws the bubble-menu for letting the user choose where to move the dice they clickedOn
   * @param  {HMTLLiEntity} clickedOn The html li element (diceface) they clicked on
  ###
  drawAllocationMoveMenuButtons: (clickedOn) ->
    @removeAllocationMoveMenu() # Need to remove the menu to create a new one.

    #Create the new allocation menu
    $('#container').append('<div id="move-allocation-menu">
      <span id="mamenu-required-btn">Required</span>
      <span id="mamenu-optional-btn">Optional</span>
      <span id="mamenu-forbidden-btn">Forbidden</span>
      </div>')


    #In general, remove the allocation menu one someone clicks any of the buttons
    $("#move-allocation-menu span").click(=>
      @removeAllocationMoveMenu()
    )

    #Add event listener for each of the "required" "optional" and "forbidden" buttons inside the menu
    $("#mamenu-required-btn").click(=>
      Network.moveToRequired($('#unallocated li').index($(clickedOn)))
    )
    $("#mamenu-optional-btn").click(=>
      Network.moveToOptional($('#unallocated li').index($(clickedOn)))
    )
    $("#mamenu-forbidden-btn").click(=>
      Network.moveToForbidden($('#unallocated li').index($(clickedOn)))
    )

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
   * We received the goal of dice. This method takes in the array of dice numbers
   * to displays them in the dom. 
  ###
  drawGoal: () ->
    $("#goal-dice-ctnr").html(DiceFace.listToHtml(Game.getGoalValues()))