$ ->
  $container = $('#portfolio #gallery_container')
  $filters = $("#portfolio #filters a")
  $opendialog = $("#portfolio #open")

  $opendialog.click ->
   myName.innerHTML = $(this).data('a')
   myUrl = $(this).data('b')
   $('#modal-blurred-bg img').attr('src', 'assets/'+myUrl)
   myCategory.innerHTML = $(this).data('c')


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

