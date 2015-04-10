#= require jquery
#= require jquery.textfill


$(document).ready ->
  $('.textfill').textfill
    innerTag: 'h1'
    minFontPixels: 11
    maxFontPixels: 32
    success: (el) ->
      $el = $('h1', el)
      $el.css('line-height', $el.css('font-size'))
