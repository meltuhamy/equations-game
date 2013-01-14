###*
 * class EndRoundScreen extends Screen
###
class EndRoundScreen extends Screen
  
  # {String} The filename of the html file to load the screen.
  file: 'endround.html'


  constructor: () ->


  # json = {solutions: the array of goal dice for possible players}
  init: (json) ->
    # Information about the end of round is provided in the json
    # Put these into local variables so that they can be accessed by rest of class.
    # ------------------------------------------------------------------------------
    @solutions = json.solutions
    @answerExists = json.answerExists
    @challengePts = json.challengePts
    @decisionPts = json.decisionPts
    @solutionPts = json.solutionPts
    # Draw the different components of the screen. Make method calls to draw 
    # goal (top), results (middle) and the ready button (bottom). Change the 
    # title of the page appropriately to give the round number in the title.
    # ----------------------------------------------------------------------
    @drawResultsList()
    @drawGoal()
    @addReadyButtonListener()
    $('h2#end-round-title').html('End of Round ' + Game.state.currentRound)
    # Play a nice sound for the end of the round which sounds like 'pwooow'.
    Sound.play('endOfRound')

  ###*
   * At the bottom of the screen, there is a ready for next round button. 
   * Add an click handler to say make a network call; telling server we are ready.
  ###
  addReadyButtonListener: () ->
    # Add the click listener to the button:
    # -------------------------------------
    $('#next-round-ready-btn').bind 'click', ->
      # Tell the server we are ready:
      # ------------------------------
      network.sendNextRoundReady()
      # Add an effect that hides the button and displays a message
      # saying that we are waiting for other players
      # ------------------------------
      $('#ready-round-cntr').fadeOut -> 
        $(this).html('')
        # &#10004; is a tick symbol
        html = '<p>&#10004; Waiting for other players...</p>'
        $(html).appendTo(this)
        $(this).fadeIn()


  ###*
   * At the end of the round, at the top, show the goal dice and stuff about the challenge.
  ###
  drawGoal: () ->
    # Show the goal dice at the top of the end round screen.
    $('#goal-dice-ctnr').html(DiceFace.listToHtmlByIndex(Game.globalDice, Game.goal))

    # What was the challenge? Was the challenge successful or not? 
    # Show a title saying 'Now Challenge' or 'Never Challenge'
    # Show a title saying whether the challenge was successful or not. 
    # -----------------------------------------------------------------
    html = '<span id="challenge-title">' + Game.getChallengeName() + '</span> '
    @challengeSuccessful = false
    if(Game.challengeModeNow && @answerExists) then @challengeSuccessful = true
    if(!Game.challengeModeNow && !@answerExists) then @challengeSuccessful = true
    if(@challengeSuccessful)
        html += '<span id="challenge-success-title" class="successful">Successful</span>'
    else
        html += '<span id="challenge-success-title" class="failure">Failure</span>'
    $('#challenge-titles-cntr').html(html)



  ###*
   * Render the resutls of the round.
   * @return {String} The html container the table for the list of rooms
  ###
  drawResultsList: () ->
    html = '<table id="resultslist">'

    # The header of the results table. Make a tr with th's for each heading in table
    # -------------------------------------------------------------------------------
    html += '<tr>'
    html += '<th>Player</th>'
    html += '<th>Points this Round</th>'
    html += '<th>Equation</th>'
    html += '<th>Total Score</th>'
    html += '</tr>'

    for p in Game.players
      html += '<tr>'
      html += "<td>#{p.name} <!-- player #{p.index} --></td>"
      agreed = Game.doesPlayerAgreeChallenge(p.index)
  
      # Give the tally of the score
      # ----------------------------
      html += "<td>"
      html += "<ul class='score-tally'>"
      if(@decisionPts[p.index]? && @decisionPts[p.index] > 0)

        # Decision points - did he get points for agreeing correctly.
        # -----------------------------------------------------------
        if(agreed)
          html += "<li><span class='scorebubble'>+" + @decisionPts[p.index] + '</span> Agreed with Challenge</li>'
        else
          html += "<li><span class='scorebubble'>+" + @decisionPts[p.index] + '</span> Didn\'t Agree with Challenge</li>'

        # Solutions points - if he make the right decision - explain the points for his solution
        # Notice that we don't bother explaining points for his solution if he didn't even get any decision points.
        # ----------------------------------------------------------------------------------------------------------
        if(@solutions[p.index]?)
          if(@solutionPts[p.index]? && @solutionPts[p.index] > 0)
            html += "<li><span class='scorebubble'>+" + @solutionPts[p.index] + '</span> Correct Solution</li>'
          else
            html += "<li class='bad'><span class='scorebubble zero'>0</span></span> Incorrect Solution</li>"
        
        # Challenger bonus points
        if(@challengePts[p.index]? && @challengePts[p.index] > 0)
          html += "<li><span class='scorebubble'>+" + @challengePts[p.index] + '</span> Made Successful Challenge</li>'
      else
        # What a flop. He agreed with the failed challenge. Tell him he sucks.
        # Don't bother telling him he got zero points for his solution.
        # ---------------------------------------------------------------------
        if(agreed)
          html += "<li class='bad'><span class='scorebubble zero'>0</span> Agreed with Challenge</li>"
        else
          html += "<li class='bad'><span class='scorebubble zero'>0</span> Didn\'t Agree with Challenge</li>"
      html += "</ul>"
      html += "</td>"

      # Show the solution that the player submitted (if he did submit one)
      # -------------------------------------------------------------------
      if(@solutions[p.index]?)
        html += "<td><ul class='solution'>"+DiceFace.drawDiceList(@solutions[p.index])+'</ul></td>'
      else
        html += "<td><p class='no-solution'>No solution</br>submitted</p></td>"
      
      # Show the player's total score
      # -----------------------------
      html += "<td>" + Game.state.playerScores[p.index] + " Points</td>"
      # End of Row
      html += '</tr>'

    # End of Table
    html += '</table>'
    $('#round-results-ctnr').html(html) # Put the html in the container