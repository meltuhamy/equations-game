class LobbyScreen extends Screen
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

  loadRooms: (jsons) ->
    # @addEventListeners

  renderRoomList: () ->
    console.log "renderRoomList!"
    console.log @games
    html = '<table id="gameslist">'
    for g in @games
      html += '<tr data-room-number="' + g.roomNumber + '">'
      html += "<td ><a href='#'>#{g.nowjsname}</a></td>"
      html += "<td>#{g.playerCount} / #{g.playerLimit} </td>"
      html += "<td>Currently playing: #{g.started}</td>"
      html += '</tr>'  
    html += '</table>'
    $('#'+Settings.containerId).append(html)