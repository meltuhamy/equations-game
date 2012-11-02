###
class DiceFace
class NumberDiceFace extends DiceFace
    constructor: (@number) ->

class BracketsFace extends DiceFace
class BinaryOperatorDiceFace extends DiceFace
class UnaryOperatorDiceFace extends DiceFace
class PlusDiceFace extends BinaryOperatorDiceFace
    ClientAnswer - A class for storing what dice the user is currently

class ClientAnswer
    answerDice : []  # array DiceFace
    addBrackets : (start, extends) ->
        #answerDice = answerDice[0..start].concat (answerDice.) answerDice[start..extends] concat



    ClientGoal - A class for the goal. If the player is first, he sets the goal. 
    If he is not first, then he receives the goal from another player.

class ClientGoal
    settingGoalDice : []  # array DiceFace, an array used while array is setting the dice
    setGoal : (start, extends) ->
        answerDice = numbers[0..2] 
###
$(document).ready(->
  $.ajax(
    url: '/views/home.html',
    success: (data) ->
      $('#container').html(data)
      alert('Load was performed. ')
  )

  $('#unallocated ul li').click(->
    $(this).toggleClass('glow')
    $('.mat').toggleClass('glow')
  )
)