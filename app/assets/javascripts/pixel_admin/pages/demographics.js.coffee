$(document).on 'click', '.q_demographics', ->
  $('#demographics').load $(this).data().url

$(document).on 'click', '.c_demographics', (e)->
  $('#demographics').load $(this).data().url
  e.stopImmediatePropagation()  # Don't let it bubble up to the q_demographics element in the DOM
