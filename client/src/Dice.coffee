class Dice
  constructor: (@type, @value) ->
    if(@type != 'number' and @type != 'operation')
      @type = 'invalid'
    if(@type == 'number' and isNaN(@value))
      @type = 'invalid'
      ###
    if(@type == 'operator' and isNoO(@value))
      @type = 'invalid'
      ###