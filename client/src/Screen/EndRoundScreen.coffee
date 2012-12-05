class EndRoundScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'endround.html'


  constructor: () ->

  # solutions: []

  # json = {solutions: the array of goal dice for possible players}
  init: (json) ->
    @solutions = json.solutions
    @answerExists = json.answerExists
    @challengePts = json.challengePts
    @decisionPts = json.decisionPts
    @solutionPts = json.solutionPts
    @drawResultsList()
    @drawGoal()
    @addReadyButtonListener()


  addReadyButtonListener: () ->
    $('#next-round-ready-btn').bind 'click', ->
      Network.sendNextRoundReady()



  drawGoal: () ->
    $('#round-goal').html(DiceFace.listToHtmlByIndex(Game.globalArray, Game.globalDice))
    challengeTitle = Game.getChallengeName()
    $('#challenge-title').html(challengeTitle)
    $('#round-goal-dice').html(DiceFace.listToHtml(Game.getGoalValues()))
    solvedTitle = if (answerExists) then 'Solved' else 'Not Solved'
    $('#solved-title').html(solvedTitle)





  ###*
   * Render the resutls of the round.
   * @return {String} The html container the table for the list of rooms
  ###
  drawResultsList: () ->
    html = '<table id="resultslist">'
    for p in Game.players
      html += '<tr>'
      html += "<td>#{p.name}</td>"

      # Give the tally of the score
      # ----------------------------
      html += "<td>"
      html += "<ul class='score-tally'>"
      if(@decisionPts[p.index]? && @decisionPts[p.index] > 0)
        html += "<li><span class='scorebubble'>+" + @decisionPts[p.index] + '</span> Agreed with Challenge</li>'
        if(@solutionPts[p.index]? && @solutionPts[p.index] > 0)
          html += "<li><span class='scorebubble'>+" + @solutionPts[p.index] + '</span> Correct Solution</li>'
        else
          html += "<li><span class='scorebubble zero'>0</span></span> Incorrect Solution</li>"
        if(@challengePts[p.index]? && @challengePts[p.index] > 0)
          html += "<li><span class='scorebubble'>+" + @challengePts[p.index] + '</span> Challenger Bonus</li>'
      else
        html += "<li><span class='scorebubble zero'>0</span> Did\'t Agree with Challenge</li>"
      html += "</ul>"
      html += "</td>"

      # Show the solution that the player submitted (if he did submit one)
      # -------------------------------------------------------------------
      if(@solutions[p.index]?)
        html += "<td><ul class='solution'>+"+DiceFace.drawDiceList(@solutions[p.index])+'</ul></td>'
      else
        html += "<td>No solution</td>"
      html += '</tr>'
    html += '</table>'
    $('#round-results-ctnr').html(html)