#= require jquery
#= require jquery_ujs

csrfToken = null
qd = $.Deferred();
window.qr = (r)-> qd.resolve(r.segments)
sendDemograhics = ->

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

readyFn = ->
  csrfToken = $('meta[name="csrf-token"]').attr('content')

  qd.then (d)->
    $.ajax (window.location + '/quantcast'), {
      type: 'POST',
      dataType: 'json',
      data: {quantcast: JSON.stringify(d)},
      headers: {'X-CSRF-Token': csrfToken}
    }
    votingFn()
$(document).ready readyFn
$(document).on 'page:load', readyFn