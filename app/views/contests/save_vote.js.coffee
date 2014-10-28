$.gritter.add title:"Notice", text:'<%=j @notice %>'
$.post "<%= scores_path(@contest.uuid) %>", (data, testStatus, jqXHR) ->
  $.each data, (id, value) ->
    $('#studio_responses #score[data-id='+value.id+']').html(value.score)
