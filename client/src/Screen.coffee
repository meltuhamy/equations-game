class Screen

  # @abstract {String} The name of the html file that contains the screen
  file: undefined 

  # {Boolean} True when we have called load() and the file has finished loading
  hasLoaded: false

  # @abstract {String} The actual data (html) given back from the ajax call
  content: undefined 

  # @abstract {String} The name of the html file that contains the screen
  constructor: (@file) ->
    @file = @file
    @content = undefined
  onUpdatedState: () ->
  onUpdatedPlayerTurn: () ->
  onUpdatedGameList: (roomlist) ->

  ###*
   * This function is called by ScreenSystem once the page has loaded
   * @abstract
   * @param  {Json} json A json that is passed to the screen. So when we render the screen, this json contains
   *                     parameters to use for the screen's initialisation for eg, the actual content.
  ###
  init: (json) -> 
  

  ###*
   * Load the screen via ajax. Load dynamically from the server, the view-file given by param in constructor.
   * @param  {Function} callback Once the file has loaded, execute the body of this function.
  ###
  load: (callback) ->
    $.ajax(
      url: "views/" + @file,
      success: (data) =>
        @hasLoaded = true
        @content = data
        callback()
    )


