$(document).ready ->
  $('[data-image]').each ->
    $el = $(this)
    data = $el.data().image
    img = new Image
    deferred = $.Deferred()

    img.onload = ->
      deferred.resolve(this.width, this.height)

    deferred.then (width, height) ->
      cssOpts =
        'background-image': "url(#{data.url})"

      if data.meta
        scale = data.meta.scale
        bgWidth = scale * width
        bgHeight = scale * height

        $.extend cssOpts,
          'background-size': "#{bgWidth}px #{bgHeight}px"
          'background-position': "#{data.meta.left}px #{data.meta.top}px"

      $el.css(cssOpts)

    img.src = data.url
