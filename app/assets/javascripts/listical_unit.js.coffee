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
      $el.parent().find('.score').text result.score
    .fail (response)->
      responseData = JSON.parse(response.responseText)
      if (responseData.error)
        alert(responseData.error)

$(document).ready votingFn
$(document).on 'page:load', votingFn