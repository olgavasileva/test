$ ->
  $container = $('#portfolio #gallery_container')
  $filters = $("#portfolio #filters a")

  $container.imagesLoaded -> 
    $container.isotope
      itemSelector: '.photo'
      masonry:
        columnWidth: 100

  # filter items when filter link is clicked
  $filters.click ->
    $filters.removeClass "active"
    $(this).addClass "active"
    selector = $(this).data('filter')
    $container.isotope
      filter: selector
    false