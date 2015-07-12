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
  return false unless cta.enabled || $overlays.length > 0

  # Figure out our start time
  randomStart = Math.random() * (cta.maxStart - cta.minStart) + cta.minStart
  console.log('Random Start', randomStart)

  # Runs the actual call to action variables
  runCallToAction = ->
    $overlays.fadeIn cta.fadeSpeed, ->
      return if window.ctaTimeoutCleared
      window.ctaFadeOutTimeout = setTimeout ->
        return if window.ctaTimeoutCleared
        $overlays.fadeOut(cta.fadeSpeed)
      , cta.duration

    window.ctaRepeatTimeout = setTimeout(runCallToAction, cta.repeat)

  window.ctaRepeatTimeout = setTimeout(runCallToAction, randomStart)
