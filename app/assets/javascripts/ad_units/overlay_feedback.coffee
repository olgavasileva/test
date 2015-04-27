$(document).ready ->
  return false unless adUnitConfig.feedback.enabled

  $q = $('#question')

  $('.image-choice, .order-choice-bar').each ->
    $el = $(this)
    $parent = $(this).parent()
    $('.overlay', $el).css
      width: $el.width()
      height: $el.height()
      postion: 'fixed'

  preventSubmit = (e) ->
    e.preventDefault()
    return false

  toggleOverlay = ($el, show) ->
    $('.overlay', $el).toggle(show)

  submitForm = ($form) ->
    $form.off('submit', preventSubmit)
    $form.submit()

  autoSubmit = (e) ->
    e.preventDefault()
    window.clearCta()

    $button = $(this)
    $form = $button.closest('form')
    $form.on('submit', preventSubmit)

    toggleOverlay($form, true)

    setTimeout ->
      submitForm($form)
    , adUnitConfig.feedback.duration

  if $q.hasClass('TextChoiceQuestion')
    $('button').on('click', autoSubmit)

  else if $q.hasClass('ImageChoiceQuestion')
    $('button').on('click', autoSubmit)

  else if $form = $('#multiple-choice-form')
    $submit = $('#multiple-choice-submit')
    data = $form.data()
    $submit.attr('disabled', 'disabled')

    $('.image-choice').click (e) ->
      window.clearCta()
      e.preventDefault()

      $el = $(@)
      $overlay = $('.overlay', $el)
      overlayVisible = $overlay.is(':visible')

      id = $el.data('choice-id')

      if overlayVisible
        $("input#choice-#{id}").remove()
      else if $('input.input-choice').length >= data.max
        return false
      else
        $input = $ '<input>',
          id: "choice-#{id}",
          name: 'response[choice_ids][]'
          class: 'input-choice'
          type: 'hidden'
          value: id

        $input.appendTo($form)

      toggleOverlay($el, !overlayVisible)

      if $('input.input-choice').length >= data.min
        $submit.attr('disabled', false)
      else
        $submit.attr('disabled', 'disabled')
