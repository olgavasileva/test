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

        makeItResponsive = ->
          $body = $('.responsive_rectangle')

          widthScale = parseInt($body.css('width'))/330
          heightScale = parseInt($body.css('height'))/405

          resizeCssOpts =
            'background-size': "#{bgWidth * widthScale}px #{bgHeight * heightScale}px"
            'background-position': "#{data.meta.left * widthScale}px #{data.meta.top * heightScale}px"

          $el.css(resizeCssOpts)
        window.onload = makeItResponsive
        window.onresize = makeItResponsive
        makeItResponsive()

      $el.css(cssOpts)

    img.src = data.url
