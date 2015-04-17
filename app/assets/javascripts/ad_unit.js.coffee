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

  $('#embed-select').change (e) ->
    e.preventDefault()
    data = $("option:selected", this).data()
    url = $(this).data('url').replace('__ad_unit_name__', data.name)
    tmpl  = "<iframe src='#{url}' width='#{data.width}' height='#{data.height}'></iframe>"
    $('#embed-input').val(tmpl)

  $("#embed-input").focus -> $(this).select()
  $('#embed-select').change()

  $('#embed-icon, #embed-close').click (e) ->
    e.preventDefault()
    $('#embed').toggle()

  # ----------------------------------------------------------------------------
  # Auto Forward
  #
  if $q.hasClass('has-response')
    console.log('has-response')
    delay = adUnitConfig.embeddable_unit_auto_forward * 1000
    next = -> document.getElementById('next-button').click()
    # setTimeout(next, delay)

  # ----------------------------------------------------------------------------
  # OrderQuestion
  #
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

  # ----------------------------------------------------------------------------
  # OrderQuestion
  #
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
