$ ->
  window.toggleEditGroup = (id) ->
    $group = $("#edit_group_#{id}")

    submitting = $group.css('display') != 'none'
    if submitting
      $group.submit()
    else
      $group.toggle()

  window.addUserToGroup = (userId, groupId) ->
    $form = $('form#new_group_member')
    $form.find('input#user_id').val(userId)
    $form.find('input#group_id').val(groupId)
    $form.submit()

  window.removeUserFromGroup = (userId, groupId) ->
    $form = $('form#destroy_group_member')
    $form.find('input#user_id').val(userId)
    $form.find('input#group_id').val(groupId)
    $form.submit()
