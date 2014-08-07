$ ->
  change_image_by = (delta) ->
    $image = $(".bgimage img")
    $id_field = $(".id input")

    ids = $(".canned").data("ids")
    urls = $(".canned").data("urls")
    max = urls.length

    i = $.inArray $image.attr("src"), urls

    if i >= 0
      i = i + delta

      if i < 0
        i += max
      else
        i = i % max

      $image.attr "src", urls[i]
      $id_field.val ids[i]

  $(document).on "click", ".image_control a.next_image", (e)->
    e.preventDefault()
    change_image_by 1

  $(document).on "click", ".image_control a.prev_image", (e)->
    e.preventDefault()
    change_image_by -1
