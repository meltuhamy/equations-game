class Screen
  file: undefined
  hasLoaded: false
  content: undefined
  constructor: (@file) ->
  init: () -> #This function gets called once the page has loaded
  load: (callback) ->
    console.log @file
    $.ajax(
      url: "views/" + @file,
      success: (data) =>
        @hasLoaded = true
        @content = data
        callback()
    )


