class DiceFace
  # A json that prevents writing magic numbers for dice faces.
  # This gets sent to the client. 
  @symbols: 
      bracketL    : -8
      bracketR    : -7
      sqrt        : -6
      power       : -5
      multiply    : -4
      divide      : -3
      plus        : -2
      minus       : -1
      zero        : 0
      one         : 1
      two         : 2
      three       : 3
      four        : 4
      five        : 5
      six         : 6
      seven       : 7
      eight       : 8
      nine        : 9
  # How many operators do we have in symbols
  @numOps      : 4

  ###*
   * Print dice faces so that can for e.g. be printed in console.
   * @param  {Integer} face [description]
   * @return {String}      [description]
  ###
  @getString: (face) ->
    if 0 <= face <=0
      "#{face}"
    else
      switch face
        when @bracketL then "("
        when @bracketR then ")"
        when @sqrt     then "sqrt"
        when @power    then "^"
        when @multiply then "*"
        when @divide   then "/"
        when @plus     then "+"
        when @minus    then "-"

module.exports.DiceFace = DiceFace
