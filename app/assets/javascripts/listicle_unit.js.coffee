#= require jquery
#= require jquery_ujs

votingFn = ->
  $('a.vote').click (e)->
    $el = $(this)
    e.preventDefault()
    e.stopPropagation()
    return if ($el.hasClass('disabled'))
    removeDisabledClasses = ->
      $el.parent().find('a').removeClass('disabled')
    $.ajax
      url: $el.attr('href')
      method: 'POST'
    .done (result)->
      $el.parent().find('.score').text result.score
      removeDisabledClasses()
      $el.addClass('disabled')

$(document).ready votingFn
$(document).on 'page:load', votingFn