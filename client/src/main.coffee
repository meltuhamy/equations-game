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
  constructor: (@file) ->
  load: (callback) ->
    $.ajax(
      url: "views/" + @file,
      success: (data) =>
        @hasLoaded = true
        @content = data
        #alert('Load was performed. ')
        callback()
    )


class ScreenSystem
  numberLoaded: 0
  screens: []
  totalScreens: () -> @screens.length
  allLoaded: false
  currentScreenId: undefined
  currentScreen: undefined
  container: undefined
  constructor: (containerId) ->
    @container = $(containerId)
  renderScreen: (screenId) ->
    if(@getScreen(screenId).hasLoaded)
      @updateCurrentScreen(screenId)
      @container.html(@currentScreen.content)
    else 
      throw "SCREEN HASNT LOADED"
  updateCurrentScreen: (screenId) ->
    @currentScreenId = screenId
    @currentScreen = @screens[screenId]
  addScreen: (filename) ->
    @screens.push(new Screen(filename)) - 1 # Push returns length after the item is added
  getScreen: (screenId) -> 
    @screens[screenId]
  loadAllScreens: (callback) ->
    for screen in @screens 
      if !screen.hasLoaded
        screen.load(=> 
          @numberLoaded++
          if(@numberLoaded >= @totalScreens())
            @allLoaded = true
            callback()
        )

$(document).ready(->
  screensystem = new ScreenSystem("#container")
  homeScreenId = screensystem.addScreen('home.html')
  goalScreenId = screensystem.addScreen('goal.html')
  console.log goalScreenId
  console.log homeScreenId
  screensystem.loadAllScreens(->screensystem.renderScreen(goalScreenId))
  $('#unallocated ul li').click(->
    $(this).toggleClass('glow')
    $('.mat').toggleClass('glow')
  )
)