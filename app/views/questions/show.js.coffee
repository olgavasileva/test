content = $("#question-modal .modal-content")
content.fadeOut ->
  content.html "<%= j(render "show")%>"
  content.fadeIn()
  $("#question-modal").modal().show()
