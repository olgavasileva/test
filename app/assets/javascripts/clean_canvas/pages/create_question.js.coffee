$ ->
  change_image_by = (delta, scope) ->
    if(!window.tcHAndlers)
      window.tcHAndlers={}

    if(!window.tcHAndlers.usedImages)
      window.tcHAndlers.usedImages=[]

    url=''
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

      url=urls[i]
      if(window.tcHAndlers.usedImages.indexOf(url)>=0)
        change_image_by (delta+delta/Math.abs(delta)),scope
      else
        current_url=$image.attr "src"
        current_ul_id=window.tcHAndlers.usedImages.indexOf current_url

        if(current_ul_id>=0)
          window.tcHAndlers.usedImages.splice current_ul_id, 1
        $image.attr "src", url
        $id_field.val ids[i]
        window.tcHAndlers.usedImages.push url

  $(document).on "click", ".image_control a.next_image", (e)->
    e.preventDefault()
    change_image_by 1, $(this).closest(".imagechooser")

  $(document).on "click", ".image_control a.prev_image", (e)->
    e.preventDefault()
    change_image_by -1, $(this).closest(".imagechooser")
