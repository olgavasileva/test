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
        $("input[name*=position]",$item).val(index+1)