#= require countUp

$(document).ready ->
  config = adUnitConfig.responseAnimation
  return unless config.enabled

  $('[data-response]').each ->
    $el = $(this)
    ratio = $el.data('response')

    $graph = $('.bar-graph', $el)
    $ratio = $('.bar-response', $el)

    counter = new countUp $ratio.get(0), 0, ratio, 0, config.speed/1000,
      suffix: '%'

    counter.start()
    $graph.animate({width: ratio + '%'}, config.speed)
