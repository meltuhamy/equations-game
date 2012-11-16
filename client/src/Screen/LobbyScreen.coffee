class LobbyScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'lobby.html'

  # {Json[]} An array with json objects describing the games
  games: []
  constructor: () -> 

  ###*
   * Load the Game Screen. This screen that shows once the goal has been set.
   * @param {Json} json = {gameListJson: A json with the list of games} .
  ###
  init: (json) ->
    @games = json.gameListJson
    @renderRoomList()
    @addClickListeners()

  ###*
   * Add event listeners to the rows so when you click to join a game, a event fires; calling Network
  ###
  addClickListeners: () ->
    thisReference = this
    gamesList = $('#gameslist tr')
    gamesList.bind 'click', (event) ->
      gameNumber = $(this).data('gamenumber')
      Network.sendJoinGameRequest(gameNumber)

  ###*
   * Render the list of rooms inside the rooms container
   * @return {String} The html container the table for the list of rooms
  ###
  renderRoomList: () ->
    html = '<table id="gameslist">'
    for g in @games
      html += '<tr data-gamenumber="' + g.gameNumber + '">'
      html += "<td ><a href='#'>#{g.nowjsname}</a></td>"
      html += "<td>#{g.playerCount} / #{g.playerLimit} </td>"
      if(g.started)
        html += "<td>Currently playing!</td>"
      else
        html += "<td>Waiting for players...</td>"
      html += '</tr>'  
    html += '</table>'
    $('#gameslistcontainer').html(html)