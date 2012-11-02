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
class Screen
  file: undefined
  hasLoaded: false
  content: undefined
  constructor: (@file, screenSystem) ->
    $.ajax(
      url: "views/" + @file,
      success: (data) ->
        @hasLoaded = true
        @content = data
        alert('Load was performed. ');
        screenSystem.onAssetLoad()
    )


class ScreenSystem
  numberLoaded: 0
  totalAssets: 0
  allLoaded: false
  currentScreen: undefined
  container: undefined
  constructor: (containerId, @screens, @callback) ->
    @container = $(containerId)
    @totalAssets = @screens.length
  renderScreen: (theScreen) ->
    @currentScreen = theScreen
    if(theScreen.hasLoaded) then container.html(theScreen.content) else throw "SCREEN HASNT LOADED";
  onAssetLoad: () ->
    @numberLoaded++
    @allLoaded = (@numberLoaded >= @totalAssets)
    if(@allLoaded) then @callback()



$(document).ready(->
  screensystem = new ScreenSystem("#container", [homeScreen, goalScreen], -> alert ("mmmm"))
  homeScreen = new Screen('home.html', screensystem)
  goalScreen = new Screen('goal.html', screensystem)

  $('#unallocated ul li').click(->
    $(this).toggleClass('glow')
    $('.mat').toggleClass('glow')
  )
)