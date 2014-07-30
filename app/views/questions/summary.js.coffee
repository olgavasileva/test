content = $(".modal.question .modal-content")
content.fadeOut ->
  content.html "<%= j(render "summary")%>"
  content.fadeIn()
  $(".modal.question").modal('show')
