#
# Common
#

#= require jquery
#= require jquery_ujs
#= require jquery.ui.all
#= require turbolinks

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
#= require_self

#
# hisrc (retina support)
#

$ ->
  $('img').hisrc(srcIsLowResolution:false, forcedBandwidth:'high')
