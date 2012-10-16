class Dice
  constructor: (@type, @value) ->
    if(@type != 'number' and @type != 'operation')
      @type = 'invalid'
    