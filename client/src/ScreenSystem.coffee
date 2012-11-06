class ScreenSystem
  # {Number} The total number of screens that have finished loaded
  @numberLoaded: 0

  # {Screen[]} An array of screens adding to the system using addScreen()
  @screens: []

  # The total number of screens added to the system using addScreen()
  @totalScreens: () -> @screens.length

  # True only when we have called loadAllScreens(), and all the screens added have loaded
  @allLoaded: false

  # The index to screens array of the screen currently loaded in document
  @currentScreenId: undefined

  # The screen object that is currently loaded in document
  @currentScreen: undefined

  # The DocumentElement object of the container where screens are loaded
  @container: undefined

  ###*
   * Tell the ScreenSystem to load in a screen. Can only be done after loadAllScreens()
   * @param  {Number} screenId The index to the array of screens of the screen to show.
  ###
  @renderScreen: (screenId) ->
    if(@getScreen(screenId).hasLoaded)
      @updateCurrentScreen(screenId)
      @container.html(@currentScreen.content)
      @currentScreen.init()
    else 
      throw "SCREEN HASNT LOADED"

  ###*
   * Update variables to change which screen is the current screen showing.
   * @private
   * @param  {Number} screenId The index to the array of screens of the screen that is now 'current'.
  ###
  @updateCurrentScreen: (screenId) ->
    @currentScreenId = screenId
    @currentScreen = @screens[screenId]

  ###*
   * Add a screen to the system to that we can load it and render it.
   * @param {Screen} screen The screen object to add to the system.
  ###
  @addScreen: (screen) -> # Screen screen
    @screens.push(screen) - 1 # Push returns length after the item is added

  ###*
   * Return a screen by its index (id)
   * @param  {[type]} screenId The index to the array of screens of the screen we want.
   * @return {Screen} The screen object in system corresponding to screenId
  ###
  @getScreen: (screenId) -> 
    @screens[screenId]

  ###*
   * Load all the screens that have been added to the system.
   * @param  {Function} callback Once all screens have been loaded, this function will be called.
  ###
  @loadAllScreens: (callback) ->
    @container = $("#" + Settings.containerId)
    for screen in @screens 
      if !screen.hasLoaded
        screen.load(=> 
          @numberLoaded++
          if(@numberLoaded >= @totalScreens())
            @allLoaded = true
            callback()
        )
