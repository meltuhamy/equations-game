
$(document).ready ->
  $('#unallocated ul li').click(->
    $(this).toggleClass('glow')
    
    ###
    $('#forbidden').popover({content: 'Now click here!', placement: 'top'})
    $('#forbidden').popover('show')

    $('#optional').popover({content: 'Now click here!', placement: 'top'})
    $('#optional').popover('show')

    $('#required').popover({content: 'Now click here!', placement: 'top'})
    $('#required').popover('show')
    ###

    $('.mat').toggleClass('glow')

  )