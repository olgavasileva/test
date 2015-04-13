#= require jquery
#= require jquery.textfill
#= require Sortable.min


$(document).ready ->
  $question = $('#question')

  $('.textfill').textfill
    innerTag: 'h1'
    minFontPixels: 11
    maxFontPixels: 32
    success: (el) ->
      $el = $('h1', el)
      $el.css('line-height', $el.css('font-size'))

  # OrderQuestion

  if $question.hasClass('OrderQuestion')
    $submit = $('#order-choice-submit')

    sort = document.getElementById('order-choice-sort')
    sortable = Sortable.create sort,
      scroll: false
      disabled: $question.hasClass('has-response')
      onStart: -> $submit.attr('disabled', 'disabled')
      onEnd: ->
        $('.order-choice-bar').each (index)->
          id = $(@).data('choice-id')
          $("#index-#{index}").val(id)

        $submit.attr('disabled', false)
