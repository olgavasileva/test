$ ->
  window.addUserToCommunity = (userId, communityId) ->
    $form = $('form#new_community_member')
    $form.find('input#user_id').val(userId)
    $form.find('input#community_id').val(communityId)
    $form.submit()

  window.removeUserFromCommunity = (userId, communityId) ->
    $form = $('form#destroy_community_member')
    $form.find('input#user_id').val(userId)
    $form.find('input#community_id').val(communityId)
    #$form.submit()
