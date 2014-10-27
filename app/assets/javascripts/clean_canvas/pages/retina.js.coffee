#
# hisrc (retina support)
#

everypage = ->
  # $('img').hisrc(srcIsLowResolution:false)

# This is to accomodate turbolinks loads
$(document).on "page:load", ->
  everypage()

# This is to accomodate full page loads
$ ->
  everypage()
