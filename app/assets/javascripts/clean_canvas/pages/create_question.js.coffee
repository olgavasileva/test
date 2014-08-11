$ ->
  change_image_by = (delta, scope) ->
    $image = $(scope).find(".bgimage img")
    $id_field = $(scope).find(".id input")

    ids = $(scope).find(".canned").data("ids")
    urls = $(scope).find(".canned").data("urls")
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
    change_image_by 1, $(this).closest(".imagechooser")

  $(document).on "click", ".image_control a.prev_image", (e)->
    e.preventDefault()
    change_image_by -1, $(this).closest(".imagechooser")
