#= require jquery
#= require jquery_ujs

votingFn = ->
  $('a.vote').click (e)->
    e.preventDefault()
    e.stopPropagation()
    $el = $(this)
    $.ajax
      url: $el.attr('href')
      method: 'POST'
    .done (result)->
      console.log result.score
      $el.parent().find('.score').text result.score
    .fail((result)-> console.log(result))

$(document).ready votingFn
$(document).on 'page:load', votingFn