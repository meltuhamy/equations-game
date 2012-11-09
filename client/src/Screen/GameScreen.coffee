class HomeScreen extends Screen
  file: 'game.html'
  constructor: () -> 

  ###*
   * Load the Game Screen. This screen that shows once the goal has been set.
   * @param {Json} json Empty.
  ###
  init: (json) ->
    @drawGoal()
    @drawDiceAllocations()

  ###*
   * We received the next turn in the game
  ###
  drawDiceAllocations: () ->
    $("#required").html(DiceFace.listToHtml(Game.getState().required))
    $("#optional").html(DiceFace.listToHtml(Game.getState().optional))
    $("#unallocated").html(DiceFace.listToHtml(Game.getState().unallocated))
    @addClickListeners()


  addClickListeners: () ->
    thisReference = this
    resourceList = $('#unallocated li')
    resourceList.bind 'click', (event) ->
      thisReference.drawAllocationMoveMenu(this);


  drawAllocationMoveMenuButtons: (clickedOn) ->
    @removeAllocationMoveMenu()
    $('#container').append('<div id="move-allocation-menu">
      <span id="mamenu-required-btn">Required</span>
      <span id="mamenu-optional-btn">Optional</span>
      <span id="mamenu-forbidden-btn">Forbidden</span>
      </div>')
    $("#mamenu-required-btn").click(=>
      Network.moveToRequired($('#unallocated li').index($(clickedOn)))
      @removeAllocationMoveMenu()
    )
    $("#mamenu-optional-btn").click(=>
      Network.moveToOptional($('#unallocated li').index($(clickedOn)))
      @removeAllocationMoveMenu()
    )
    $("#mamenu-forbidden-btn").click(=>
      Network.moveToForbidden($('#unallocated li').index($(clickedOn)))
      @removeAllocationMoveMenu()
    )

  drawAllocationMoveMenu: (clickedOn) ->
    @drawAllocationMoveMenuButtons(clickedOn)
    borderOffset = parseInt($(clickedOn).css('border-width'), 10) 
    $('#move-allocation-menu').css(
      left: $(clickedOn).position().left + ($(clickedOn).width()-borderOffset)/2
      top: $(clickedOn).position().top + $(clickedOn).height() + borderOffset
    )

  removeAllocationMoveMenu: ()->
    allocMenu = $('#move-allocation-menu')
    console.log allocMenu
    $('#move-allocation-menu').remove() if allocMenu.length > 0


  ###*
   * We received the goal of dice. This method takes in the array of dice numbers
   * to displays them in the dom. 
  ###
  drawGoal: () ->
    $("#goal").html(DiceFace.listToHtml(Game.getGoalValues()))