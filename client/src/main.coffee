
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