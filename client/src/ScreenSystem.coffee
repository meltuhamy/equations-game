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
    @currentScreen.init()
  addScreen: (screen) -> # Screen screen
    @screens.push(screen) - 1 # Push returns length after the item is added
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
