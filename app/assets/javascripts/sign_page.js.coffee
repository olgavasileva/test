#= require jquery

$(document).ready ->
  $('#forgot-password-link').click ->
    $('#password-reset-form').fadeIn(400)
    false

  $('#password-reset-form .close').click ->
    $('#password-reset-form').fadeOut(400)
    false

  $ph = $('#page-signin-bg')
  $img = $ph.find('> img');

  resizeBg = ->
    $img.attr('style', '')
    if ($img.height() < $ph.height())
      $img.css
        height: '100%'
        width: 'auto'
  $(window).on 'resize', resizeBg
  setTimeout $(window).resize, 0
