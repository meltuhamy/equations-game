###*
 * class ScreenSystem
###
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
   * @param  {Json} json A json that is passed to the screen. So when we render the screen, this json contains
   *                     parameters to use for the screen's initialisation for eg, the actual content.
   * @param  {Number} screenId The index to the array of screens of the screen to show.
  ###
  @renderScreen: (screenId, json) ->
    # if the screen has loaded, change the current screen var, 
    # load-in the html & call the screen's init function. If not loaded, throw an exception
    if(@getScreen(screenId).hasLoaded)
      @updateCurrentScreen(screenId)
      @container.html(@currentScreen.content)
      @currentScreen.init(json)
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
   * @param  {Number} screenId The index to the array of screens of the screen we want.
   * @return {Screen} The screen object in system corresponding to screenId
  ###
  @getScreen: (screenId) -> 
    @screens[screenId]

  ###*
   * Return a screen that has currently been chosen to be rendered
   * @param  {Number} screenId The index to the array of screens of the screen we want.
   * @return {Screen} The screen object in system corresponding to screenId
  ###
  @getCurrentScreen: () -> 
    @screens[@currentScreenId]


  ###*
   * Load all the screens that have been added to the system.
   * @param  {Function} callback Once all screens have been loaded, this function will be called.
  ###
  @loadAllScreens: (callback) ->
    @container = $("#" + Settings.containerId)
    for screen in @screens 
      # If the screen hasn't loaded, then load it - 
      # give ajax a callback that updates how many screens have loaded
      # Also call the callback parameter when it has loaded
      if !screen.hasLoaded
        screen.load(=> 
          @numberLoaded++
          if(@numberLoaded >= @totalScreens())
            @allLoaded = true
            callback()
        )


  ###*
   * Give the screen an error passed from the server.
   * @param  {Json} errorObject callback Information about the error.
  ###
  @receiveServerError: (errorObject) ->
    if(@currentScreen?)
      if(@currentScreen.hasLoaded)
        @currentScreen.receiveServerError()



