###*
 * class LobbyScreen extends Screen
###
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
      $('#newgame-player-name').focus() #Focus on the first input element to make user know he has to do something

    $('#new-game').submit (event) -> event.preventDefault()


    # When we have submitted the 
    thisReference = this
    $('#add-game-btn').unbind 'click'
    $('#add-game-btn').bind 'click', (event) ->
      gameName = $('#newgame-name').val()
      playerName = $('#newgame-player-name').val()
      numPlayers = parseInt($('#newgame-numplayers').val())
      difficulty = $('#newgame-difficulty').val()

      # Reset the erros and see if they occur
      thisReference.removeError('newgame-name-label')
      thisReference.removeError('newgame-player-name-label')
      thisReference.removeError('newgame-numplayers-label')
      thisReference.removeError('newgame-difficulty-label')

      thisReference.formErrorNum = 0

      # Validate the player name
      condition = (!playerName? || playerName == "" || playerName.length == 0)
      thisReference.handleError(condition, 'newgame-player-name-label', 'Your nickname can\'t be empty.')
      
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

      if thisReference.formErrorNum is 0 then Network.sendCreateGameRequest(gameName, numPlayers, playerName)

      return false # this return false prevents the form being submitted (causing page refresh)
   

  handleError: (errCondition, labelId, errMessage) ->
    theHtml = null
    if errCondition
      theHtml = if errMessage? then errMessage else 'Error'
      $('#' + labelId + ' span.form-error').html(theHtml)
      @formErrorNum++

  removeError: (labelId) ->
    $('#' + labelId + ' span.form-error').html('')
      

  ###*
   * Creates a bootstrap modal dialogue
   * @param  {Number} gameNumber The game number the player wants to join.
  ###
  joinGameDialog: (gameNumber) ->

    # delete the modal dialog if it already exists.
    modalsAlreadyOpen = $('#enterNameModal')
    if modalsAlreadyOpen.length isnt 0 then $('#enterNameModal').remove()

    # create the modal dialog
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
    thisReference = this
    # Once the modal dialog HTML is ready, bind click listeners and show the modal
    $(enterNameDialogHtml).appendTo('body').ready ->
      $('#joinGameWithName').click ->
        thisReference.nameEnteredFromJoinGameDialog(gameNumber)
      $('#enterNameModal').on 'shown', ->
        $('#enterNameInputId').focus() #focus on the text box so you can start typing.
        $('#enterNameInputId').keyup (e) ->
          thisReference.nameEnteredFromJoinGameDialog(gameNumber) if e.keyCode is 13 # 13 means ENTER key
      $('#enterNameModal').modal('show')

  nameEnteredFromJoinGameDialog: (gameNumber) ->
    nameEntered = $('#enterNameInputId').val()
    #TODO: Validation
    Game.joinGame(gameNumber, nameEntered)
    $('#enterNameModal').modal('hide')
    $('#enterNameModal').remove()


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


