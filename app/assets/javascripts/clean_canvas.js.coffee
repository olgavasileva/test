#
# Common
#

#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require jquery.ui.touch-punch
#= require cocoon
#= require turbolinks
#= require bootstrap-sprockets

#
# Theme files
#

#= require_tree ./clean_canvas/theme
#= require_tree ../../../vendor/assets/javascripts/loop

#
# Other
#

#= require hisrc
#= require toastr
#= require gritter
#= require jquery.ba-throttle-debounce

#
# Page files
#

#= require_tree ./clean_canvas/pages
#= require photoshoot/main

$(document).on "page:change", ->
  $(".datepicker").datepicker
    changeMonth:true
    changeYear:true
    minDate: "-20Y"
    maxDate: 0
    dateFormat:'yy-mm-dd'

# Submit any form that has a
$ ->
  $(document).on "click", "[data-btn-role=submit]", (event)->
    form = $(this).closest("form")
    if form.length == 1
      event.preventDefault();
      $(this).closest("form").submit()
