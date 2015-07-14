window.ctaRepeatTimeout = undefined
window.ctaFadeOutTimeout = undefined
window.ctaTimeoutCleared = false

window.clearCta = ->
  return if window.ctaTimeoutCleared

  clearTimeout(window.ctaRepeatTimeout)
  clearTimeout(window.ctaFadeOutTimeout)

  $icon = $('<i>', class: 'overlay-text fa fa-check')
  $('.overlay').stop(true, true).hide().html('').append($icon)

  window.ctaTimeoutCleared = true

$(document).ready ->
  cta = adUnitConfig.cta
  $overlays = $('.overlay')
  $overlays.hide()

  return false unless cta.enabled || $overlays.length > 0

  # Figure out our start time
  randomStart = Math.random() * (cta.maxStart - cta.minStart) + cta.minStart
  $overlays.css 'animation-duration', cta.duration

  overlayFn = ->
    el = $overlays.get(parseInt(Math.random() * $overlays.length))
    $(el).fadeIn cta.fadeSpeed

    setTimeout ->
      $(el).fadeOut cta.fadeSpeed
    , randomStart

  setTimeout overlayFn, randomStart

  window.ctaRepeatTimeout = setInterval overlayFn, randomStart + cta.maxStart
