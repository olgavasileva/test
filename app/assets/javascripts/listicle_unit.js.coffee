#= require jquery
#= require jquery_ujs

votingFn = ->
  $('a.vote').click (e)->
    $el = $(this)
    e.preventDefault()
    e.stopPropagation()
    $.ajax
      url: $el.attr('href')
      method: 'POST'
    .done (result)->
      $el.parent().find('.score').text result.score

$(document).ready votingFn
$(document).on 'page:load', votingFn