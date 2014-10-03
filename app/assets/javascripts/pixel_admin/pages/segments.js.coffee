$(document).on 'page:change', ->
  $("#question_search").autocomplete
    delay: 500
    minLength: 2
    source: (request, response)->
      $.get $("#question_search").data().callback, {term:request.term}, (data) ->
        result = $.map data, (hash, index) ->
          {value: hash.title, id:hash.id, url:hash.matcher_url}
        response result

    focus: (event, ui) ->
      $('#search_results').load ui.item.url

    select: (event, ui) ->
      console.log ui.item.label
      console.log ui.item.value
