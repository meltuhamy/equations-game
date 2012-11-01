

class DiceFace
class NumberDiceFace extends DiceFace
    ###*
     * Assigns the number to the DiceFace object.
     * @param {int} @number The number that appears on the dice face
    ###
    constructor: (@number) ->

class BracketsFace extends DiceFace
class BinaryOperatorDiceFace extends DiceFace
class UnaryOperatorDiceFace extends DiceFace
class PlusDiceFace extends BinaryOperatorDiceFace



###
    ClientAnswer - A class for storing what dice the user is currently
###
class ClientAnswer
    answerDice : []  # array DiceFace
    addBrackets : (start, extends) ->
        #answerDice = answerDice[0..start].concat (answerDice.) answerDice[start..extends] concat


###
    ClientGoal - A class for the goal. If the player is first, he sets the goal. 
    If he is not first, then he receives the goal from another player.
###
class ClientGoal
    settingGoalDice : []  # array DiceFace, an array used while array is setting the dice
    setGoal : (start, extends) ->
        answerDice = numbers[0..2] 



$(document).ready ->
  $('#unallocated ul li').click(->
    $(this).toggleClass('glow')
    
    ###
    $('#forbidden-mat').popover({content: 'Now click here!', placement: 'top'})
    $('#forbidden-mat').popover('show')

    $('#optional-mat').popover({content: 'Now click here!', placement: 'top'})
    $('#optional-mat').popover('show')

    $('#required-mat').popover({content: 'Now click here!', placement: 'top'})
    $('#required-mat').popover('show')
    ###

    $('.mat').toggleClass('glow')





  )