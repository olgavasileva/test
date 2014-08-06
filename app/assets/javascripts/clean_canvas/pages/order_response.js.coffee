$ ->
  init_order_response()
$(document).on "page:load", ->
  init_order_response()

init_order_response = ->
  $list = $('#orderChoices')
  $list.sortable
    handle: '.handle'
    update: ->
      $('.panel', $list).each (index, elem)->
        $item = $(elem)
        newIndex = $item.index()
        $("input[type=number]",$item).val(newIndex+1)