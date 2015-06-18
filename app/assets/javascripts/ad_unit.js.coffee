#= require jquery
#= require jquery.textfill
#= require jquery.cookie
#= require Sortable.min
#= require ad_units/image_manipulation
#= require ad_units/overlay_cta
#= require ad_units/overlay_feedback
#= require ad_units/response_animation

$ ->
  resizeText = ->
    $(".resize").textfill
      innerTag: ".cell"
      maxFontPixels: 16
      changeLineHeight: true
      complete: ->
        $(".resize .cell").animate(opacity: 1.0)

  # Resize text after font is loaded
  setTimeout resizeText, 100

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

  $('#embed-icon').click (e) ->
    e.preventDefault()
    $('#embed').toggle()

  # ----------------------------------------------------------------------------
  # Auto Forward
  #
  if adUnitConfig.autoForward.enabled && $q.hasClass('has-response')
    next = -> document.getElementById('next-button').click()
    setTimeout(next, adUnitConfig.autoForward.speed)

  # ----------------------------------------------------------------------------
  # OrderQuestion
  #
  if $q.hasClass('OrderQuestion')
    $submit = $('#order-choice-submit')

    sort = document.getElementById('order-choice-sort')
    sortable = Sortable.create sort,
      scroll: false
      disabled: $q.hasClass('has-response')
      onStart: (e) ->
        window.clearCta()
        $(e.item).css(opacity: 0)
        $submit.attr('disabled', 'disabled')
      onEnd: (e) ->
        $(e.item).css(opacity: 1)
        $('.order-choice-bar').each (index)->
          id = $(@).data('choice-id')
          $("#index-#{index}").val(id)

        $submit.attr('disabled', false)
