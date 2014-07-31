portfolio = ->
  $('#portfolio #gallery_container').imagesLoaded ->
    $('#portfolio #gallery_container').isotope
      itemSelector: '.photo'
      masonry:
        columnWidth: 100


# filter items when filter link is clicked
$ ->
  $(document).on "click", "#portfolio #filters a", ->
    $("#portfolio #filters a").removeClass "active"
    $(this).addClass "active"
    selector = $(this).data('filter')
    $('#portfolio #gallery_container').isotope
      filter: selector
    false

$ ->
  portfolio()

$(document).on "page:load", ->
  portfolio()