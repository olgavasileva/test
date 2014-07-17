<%- if @response.valid? %>
  toastr.success "Please check back later for more questions.", "Thank you for your response!"
  $(".modal.question").modal('hide')
<%- else %>
  toastr.error "<%= @response.errors.full_messages.join " " %>"
<%- end %>
