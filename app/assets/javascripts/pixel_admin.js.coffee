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


# Theme files
#

#= require ./pixel_admin/main
#= require_self

# Page files
#

#= require_tree ./pixel_admin/pages



# Start the pixel admin app so initial settings are set up before our js stuff runs
window.PixelAdmin.start()
