class DiceFace
  
  @symbols: undefined

  ###*
   * A method for printing the diceface in html form; surrounded by <li> tags
   * @param  {Number} face The dice face number to of the face to show
   * @return {String}      The html form for the diceface.
  ###
  @toHtml: (face) ->
    switch face
      when @symbols.bracketL then "("
      when @symbols.bracketR then ")"
      when @symbols.sqrt     then "sqrt"
      when @symbols.power    then "^"
      when @symbols.multiply then "*"
      when @symbols.divide   then "/"
      when @symbols.plus     then "+"
      when @symbols.minus    then "-"
      else (if face >= 0     then "#{face}")

  ###*
   * Turns an array of dicefaces into li's
   * @param  {Number[]} list The array of dicefaces
   * @return {String}         A string with the html containing li's
  ###
  @listToHtml: (list) ->
    html = '';
    html+= "<li class='dice'><span>#{@toHtml(d)}<span></li>" for d in list
    return html

