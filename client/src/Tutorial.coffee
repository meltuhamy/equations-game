class Tutorial
  @window: undefined
  @windowOptions = undefined
  @init : ->
    if $('#tutorial-window').length > 0 then $('#tutorial-window').remove()
    
    @windowOptions = 
      backdrop: false
      keyboard: false
      show: false

    html = '<div id="tutorial-window" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                <h3 id="tutorial-window-header">Equations Tutorial Game</h3>
              </div>
              <div class="modal-body" id="tutorial-window-content">
                <p>Hello!</p><p>I\'m here to show you around the basics of the equations game. Pay attention!</p>
              </div>
              <div class="modal-footer">
                <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                <button class="btn btn-primary">Save changes</button>
              </div>
            </div>'

    @window = $(html).prependTo('body')
    $(@window).modal(@windowOptions)

  @isValid: -> @window? and @window.length > 0

  @changeContent: (content) -> if @isValid then $('#tutorial-window-content').html(content)

  @changeHeader: (header) -> if @isValid then $('#tutorial-window-header').html(header)

  @changeWindow: (header, content) -> @changeHeader(header); @changeContent(content)

  @show: -> $(@window).modal('show')
  @hide: -> $(@window).modal('hide')
  @toggle: -> $(@window).modal('toggle')