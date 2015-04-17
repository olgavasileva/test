#= require jquery
#= require jquery.textfill
#= require Sortable.min


$(document).ready ->
  $q = $('#question')

  $('.textfill').textfill
    innerTag: 'h1'
    minFontPixels: 11
    maxFontPixels: 32
    success: (el) ->
      $el = $('h1', el)
      $el.css('line-height', $el.css('font-size'))

  $('a.popup').click (e) ->
    e.preventDefault()

    width = 600
    height = 400
    left = Number((screen.width/2)-(width/2))
    top = Number((screen.height/2)-(height/2))

    window.open(
      this.href,
      'Share Statisfy',
      "width=#{width},height=#{height},top=#{top},left=#{left}"
    )


  # OrderQuestion

  if $q.hasClass('OrderQuestion')
    $submit = $('#order-choice-submit')

    sort = document.getElementById('order-choice-sort')
    sortable = Sortable.create sort,
      scroll: false
      disabled: $q.hasClass('has-response')
      onStart: -> $submit.attr('disabled', 'disabled')
      onEnd: ->
        $('.order-choice-bar').each (index)->
          id = $(@).data('choice-id')
          $("#index-#{index}").val(id)

        $submit.attr('disabled', false)

  else if $q.hasClass('MultipleChoiceQuestion') && !$q.hasClass('has-response')
    $form = $('#order-choice-form')
    $submit = $('#multiple-choice-submit')
    data = $form.data()
    $submit.attr('disabled', 'disabled')

    console.log(data)

    $('.image-choice').click (e) ->
      e.preventDefault()
      $el = $(@)
      id = $el.data('choice-id')

      if $el.hasClass('selected')
        $("input#choice-#{id}").remove()
      else
        $input = $ '<input>',
          id: "choice-#{id}",
          name: 'response[choice_ids][]'
          class: 'input-choice'
          type: 'hidden'
          value: id
        $input.appendTo($form)

      $el.toggleClass('selected')

      if $('input.input-choice').length >= data.min
        $submit.attr('disabled', false)
      else
        $submit.attr('disabled', 'disabled')
