class UI
  diceFaceToString: (face, diceFaces) ->
    dicefaces = game.dicefaces
    if face >= 0
      "#{face}"
    else
      switch face
        when dicefaces.bracketL then "("
        when dicefaces.bracketR then ")"
        when dicefaces.sqrt     then "sqrt"
        when dicefaces.power    then "^"
        when dicefaces.multiply then "*"
        when dicefaces.divide   then "/"
        when dicefaces.plus     then "+"
        when dicefaces.minus    then "-"

  ###*
   * Turns an array of dicefaces into li's
   * @param  {Number[]} diceFaces The array of dicefaces
   * @return {String}         A string with the html containing li's
  ###
  diceFacesToHtml: (dicefaces) ->
    html = '';
    for d in dicefaces
      html+= "<li class='dice'><span>#{@diceFaceToString(d)}<span></li>"
    return html

  ###*
   * Displays the unallocated array by updating the dom
   * @param  {Number[]} unallocated  The unallocated array of dicefaces
  ###
  showUnallocated: (unallocated)->
    alert("WE TETRISED")
    $("#inside-goal").html(@diceFacesToHtml(unallocated))

  setGoalFromUI: ->
    $(document).ready ->

  moveToGoal: (index) ->
    $('#outisde-goal').append($("#inside-goal li:nth-child(#{index})"))
    $('#inside-goal').remove("li:nth-child(#{index})")

ui = new UI()