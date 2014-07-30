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

$ ->
  $('img').hisrc(srcIsLowResolution:false, forcedBandwidth:'high')

  $(".modal.question").modal(show:false, keyboard:true)
