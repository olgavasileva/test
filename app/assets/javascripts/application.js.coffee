#
# Common
#

#= require jquery
#= require jquery_ujs
#= require jquery.ui.all
#= require turbolinks
#= require bootstrap-sprockets

#
# Theme files
#

#= require_tree ./pixel_admin
#= require_tree ./clean_canvas
#

#
# Other
#

#= require hisrc
#= require toastr
#= require_self

#
# hisrc (retina support)
#

everypage = ->
  $('img').hisrc(srcIsLowResolution:false)

# This is to accomodate turbolinks loads
$(document).on "page:load", ->
  everypage()

# This is to accomodate full page loads
$ ->
  everypage()
