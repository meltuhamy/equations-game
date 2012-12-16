class LobbyScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'lobby.html'

  # {Json[]} An array with json objects describing the games
  games: []

  # {Number} How many errors occurred after checking the form
  formErrorNum: 0


  constructor: () -> 

  ###*
   * Load the Game Screen. This screen that shows once the goal has been set.
  ###
  init: (json) ->

  onUpdatedGameList: (roomlistroomlist) ->
    @games = roomlistroomlist
    @renderRoomList()
    @addClickListeners()


  ###*
   * Add event listeners to the rows so when you click to join a game, a event fires; calling Network
  ###
  addClickListeners: () ->
    thisReference = this
    gamesList = $('#gameslist tr')

    gamesList.unbind 'click'
    gamesList.bind 'click', (event) ->
      gameNumber = $(this).data('gamenumber')
      thisReference.joinGameDialog(gameNumber)

    $('#show-add-game-btn').unbind 'click'
    $('#show-add-game-btn').bind 'click', (event) ->
      $('#new-game-form-ctnr').slideToggle("fast")

    $('#new-game').submit (event) -> event.preventDefault()


    # When we have submitted the 
    thisReference = this
    $('#add-game-btn').unbind 'click'
    $('#add-game-btn').bind 'click', (event) ->
      gameName = $('#newgame-name').val()
      numPlayers = parseInt($('#newgame-numplayers').val())
      difficulty = $('#newgame-difficulty').val()

      # Reset the erros and see if they occur
      thisReference.removeError('newgame-name-label')
      thisReference.removeError('newgame-numplayers-label')
      thisReference.removeError('newgame-difficulty-label')
      @formErrorNum = 0

      # Validate the game name
      condition = (!gameName? || gameName == "" || gameName.length == 0)
      thisReference.handleError(condition, 'newgame-name-label', 'The name of the game can\'t be empty.')
      condition = (!gameName? || gameName.length > 20) 
      thisReference.handleError(condition, 'newgame-name-label', 'The game\'s name cannot have more than 20 characters')

      # Validate the number of players 
      condition = (!numPlayers? || numPlayers < 0 || numPlayers > 5)
      thisReference.handleError(condition, 'newgame-numplayers-label', 'Please select 2 to 5 players')

      # Validate the difficult mode
      condition = (!difficulty? || (difficulty != 'easy' && difficulty != 'hard'))
      thisReference.handleError(condition, 'newgame-difficulty-label', 'Please select either Easy or Hard')

      if(@formErrorNum == 0) then Network.sendCreateGameRequest(gameName, numPlayers)

      return false # this return false prevents the form being submitted (causing page refresh)
   

  handleError: (errCondition, labelId, errMessage) ->
    theHtml = if(errCondition) then errMessage; @errors++
    $('#' + labelId + ' span.form-error').html(theHtml)
    @formErrorNum++

  removeError: (labelId) ->
    @formErrorNum++
    $('#' + labelId + ' span.form-error').html('')
      

  joinGameDialog: (gameNumber) ->
    #Game.joinGame(gameNumber)

    modalsAlreadyOpen = $('#enterNameModal')
    if modalsAlreadyOpen.length isnt 0 then $('#enterNameModal').remove()
    enterNameDialogHtml = '<div id="enterNameModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                            <div class="modal-header">
                              <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                              <h3 id="myModalLabel">Enter your name</h3>
                            </div>
                            <div class="modal-body">
                              <p>Please enter your nickname below.<br /></p>
                              <input type="text" id="enterNameInputId" placeholder="Enter nickname here" />
                            <div class="modal-footer">
                              <span data-dismiss="modal" aria-hidden="true" class="grey-button">Cancel</span>
                              <span id="joinGameWithName" class="grey-button">Join Game</span>
                            </div>
                          </div>'
    $(enterNameDialogHtml).appendTo('body').ready ->
      $('#joinGameWithName').click ->
        nameEntered = $('#enterNameInputId').val()
        #TODO: Validation
        Game.joinGame(gameNumber, nameEntered)
        $('#enterNameModal').modal('hide')
        $('#enterNameModal').remove()
      $('#enterNameModal').modal('show')



  ###*
   * Render the list of rooms inside the rooms container
   * @return {String} The html container the table for the list of rooms
  ###
  renderRoomList: () ->
    html = '<table id="gameslist">'
    for g in @games
      html += '<tr data-gamenumber="' + g.gameNumber + '">'
      html += "<td><a href='#'>#{g.gameName}</a></td>"
      html += "<td>#{g.playerCount} / #{g.playerLimit} </td>"
      if(g.started)
        html += "<td>Currently playing!</td>"
      else
        html += "<td>Waiting for players...</td>"
      html += '</tr>'  
    html += '</table>'
    $('#gameslist-ctnr').html(html)


