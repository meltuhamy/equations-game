class DiceFace
  
  # {Json} A json that maps names to DiceFace magic numbers
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
   * @param  {Number[]} list The array of dicefaces values
   * @param  {Boolean} showIndexData Whether to add the attribute data-index to each li
   * @param  {Boolean} dots Whether to add dots li between each dice li
   * @return {String}         A string with the html containing li's
  ###
  @listToHtml: (list, showIndexData, dots) ->
    html = '';
    indexCounter = 0
    if(dots) then html += "<li class='dot' data-index='" + indexCounter + "''>.</li>"
    for d in list
      dataIndex = if (showIndexData) then " data-index='#{indexCounter}'" else ""
      html += "<li class='dice'" + dataIndex + "><span>#{@toHtml(d)}<span></li>" 
      if(dots) then html += "<li class='dot' data-index='" + indexCounter + "''>.</li>" 
      indexCounter++
    return html


  ###*
   * Turns an array of dicefaces into li's
   * @param  {Number[]} diceFaces The array of dicefaces magic numbers. Referenced by 'indices' param.
   * @param  {Number[]} The actual list of dice to be printed. An array of indices to 'diceFaces' param.
   * @param  {Boolean} showIndexData Whether to add the attribute data-index to each li
   * @param  {Boolean} dots Whether to add dots li between each dice li
   * @return {String}         A string with the html containing li's
  ###
  @listToHtmlByIndex: (diceFaces, indices, showIndexData, showRefData, dots) ->
    result = []
    result.push diceFaces[i] for i in indices
    return @listToHtml(result, showIndexData, dots)



