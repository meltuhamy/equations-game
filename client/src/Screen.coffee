###*
 * class Screen
###
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

  # @abstract Event that happens when the state json on server changes
  onUpdatedState: () ->

  # @abstract Event that happens when the server pauses the game timer
  onPauseTimer: () ->

  # @abstract Event that happens when the server resumes the game timer
  onResumeTimer: () ->

  # @abstract Event that happens when dice allocating turn it is updated
  onUpdatedPlayerTurn: () ->

  # @abstract Event that happens when the list of rooms is updated (when games added/deleted)
  onUpdatedGameList: (roomlist) ->

  # @abstract Event that happens when someone presses a key
  onKeyup: (e) ->
  
  # @abstract Pass a error json (sent from server) to the screen.
  onServerError: (errorObject) ->

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

  dialogue: (content, title, modal) ->
    $("<div />").qtip
      content:
        text: content
        title: title

      position:
        my: "center" # Center it...
        at: "center"
        target: $(window) # ... in the window

      show:
        ready: true # Show it straight away
        modal:
          on: modal # Make it modal (darken the rest of the page)...
          blur: false # ... but don't close the tooltip when clicked

      hide: false # We'll hide it maunally so disable hide events
      style: "qtip-light qtip-rounded qtip-dialogue" # Add a few styles
      events:
        
        # Hide the tooltip when any buttons in the dialogue are clicked
        render: (event, api) ->
          $("button", api.elements.content).click api.hide

        
        # Destroy the tooltip once it's hidden as we no longer need it!
        hide: (event, api) ->
          api.destroy()


  # Our Alert method
  alert: (message, modal) ->
    
    # Content will consist of the message and an ok button
    message = $("<p />",
      text: message
    )
    ok = $("<button />",
      text: "Ok"
      class: "full"
    )
    @dialogue message.add(ok), "Alert!", modal

  # Our Prompt method
  prompt: (question, initial, callback, modal) ->
    # Content will consist of a question elem and input, with ok/cancel buttons
    message = $("<p />",
      text: question
    )
    input = $("<input />",
      val: initial
    )
    ok = $("<button />",
      text: "Ok"
      click: ->
        callback input.val()
    )
    cancel = $("<button />",
      text: "Cancel"
      click: ->
        callback null
    )
    @dialogue message.add(input).add(ok).add(cancel), "Attention!", modal

  # Our Confirm method
  confirm: (question, callback, modal) ->
    # Content will consist of the question and ok/cancel buttons
    message = $("<p />",
      text: question
    )
    ok = $("<button />",
      text: "Ok"
      click: ->
        callback true
    )
    cancel = $("<button />",
      text: "Cancel"
      click: ->
        callback false
    )
    @dialogue message.add(ok).add(cancel), "Do you agree?", modal