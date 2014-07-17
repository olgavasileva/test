<%- if @just_answered %>toastr.success "Here's another one", "Thank you for your response!"<%- end %>
content = $(".modal.question .modal-content")
content.fadeOut ->
  content.html "<%= j(render "show")%>"
  content.fadeIn()
  $(".modal.question").modal('show')
