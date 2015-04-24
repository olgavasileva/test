$(document).ready ->
  $('[data-image]').each ->
    $el = $(this)
    data = $el.data().image

    cssOpts =
      'background-image': "url(#{data.url})"

    # if data.meta
    #   scale = data.meta.scale * 100
    #
    #   $.extend cssOpts,
    #     'background-size': "#{scale}%"
    #     'background-position': "#{data.meta.top}px #{data.meta.left}px"

    $el.css(cssOpts)
