# Common
#

#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require jquery.ui.touch-punch
#= require cocoon
#= require turbolinks
#= require bootstrap-sprockets
#= require hisrc
#= require toastr

#= require highcharts/highcharts
#= require highcharts/highcharts-more

# Theme files
#

#= require ./pixel_admin/main

## Morris js
#= require raphael
#= require morris

## slim scroll gem
#= require jquery.slimscroll.min

## easy as pie gem
#= require jquery.easy-pie-chart

## jquery-data-tables gem
#= require dataTables/jquery.dataTables
#= require dataTables/bootstrap/3/jquery.dataTables.bootstrap

## jquery-select2 gem
#=require select2

## Pull these from pixel_admin libs - no gems to help
#= require ./pixel_admin/libs/jquery.sparkline-2.1.2
#= require ./pixel_admin/build/extensions_jquery.sparklines
#= require ./pixel_admin/build/plugins_switcher

#= require_self

# Page files
#

#= require_tree ./pixel_admin/pages
#= require gritter
#= require tinymce-jquery
#= require redactor/redactor
#= require redactor/plugins/imagemanager
#= require redactor/plugins/video
#= require redactor/plugins/fontcolor
#= require redactor/plugins/fontfamily
#= require redactor/plugins/fontsize
#= require redactor/plugins/table
#= require listicle_unit

# Asyncronously load DOM elements from partials after page is loaded
$(document).on "page:change", ->
  $('[data-lazy]').each ->
    $.getScript $(this).data().lazy

  $(".datepicker").datepicker
    changeMonth: true
    changeYear: true

  PixelAdmin.addInitializer ->
    PixelAdmin.initPlugin 'main_menu', new PixelAdmin.MainMenu
  PixelAdmin.addInitializer ->
    PixelAdmin.initPlugin 'main_navbar', new PixelAdmin.MainNavbar
  PixelAdmin.start([])

  $body = $('body')

  $('#main-menu-toggle').click ->
    isToggled = $body.hasClass('mmc')
    if isToggled
      $body.removeClass('mmc')
    else
      $body.addClass('mmc')
