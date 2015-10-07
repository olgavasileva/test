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
      score = parseInt(result.score)
      $scoreEl = $el.parent().find('.score')
      if score >= 0
        $scoreEl.removeClass('negative')
      else
        $scoreEl.addClass('negative')
      $scoreEl.text Math.abs(result.score)

$(document).ready votingFn
$(document).on 'page:load', votingFn