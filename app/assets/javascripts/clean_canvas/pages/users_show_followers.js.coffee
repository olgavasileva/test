$ ->
  window.toggleEditGroup = (id) ->
    $group = $("#edit_group_#{id}")

    submitting = $group.css('display') != 'none'
    if submitting
      $group.submit()
    else
      $group.toggle()
