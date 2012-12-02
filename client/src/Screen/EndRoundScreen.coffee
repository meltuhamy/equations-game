class EndRoundScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'endround.html'


  constructor: () ->

  solutions: []

  # json = {solutions: the array of goal dice for possible players}
  init: (json) ->
    @solutions = json.solutions
    @renderResultsList()



  ###*
   * Render the resutls of the round.
   * @return {String} The html container the table for the list of rooms
  ###
  renderResultsList: () ->
    html = '<table id="resultslist">'
    for p in Game.players
      # If the player submitted a solution then 
      if(p.index in Game.state.possiblePlayers)
        html += '<tr>'
        html += "<td>#{p.name}</td>"
        html += "<td>" + DiceFace.listToHtmlByIndex(Game.globalDice, @solutions[p.index]) + '</td>'
        html += '</tr>'
      if(p.index in Game.state.impossiblePlayers)
        html += '<tr>'
        html += "<td>#{p.name}</td>"
        if(Game.challengeModeNow)
          html += "<td>Didn\'t agree and so didn\'t provide a solution.</td>"
        else
          html += "<td>Agreed and so didn\'t provide a solution.</td>"
        html += '</tr>'

    html += '</table>'
    $('#round-results-ctnr').html(html)